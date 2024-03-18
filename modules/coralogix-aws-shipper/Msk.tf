resource "aws_iam_role" "role_for_msk" {
  count              = var.msk_cluster_arn != null ? 1 : 0
  name               = "coralogix_role_msk_lambda_trigger"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "secrets_policy" {
  count      = (var.store_api_key_in_secrets_manager || local.api_key_is_arn) && var.msk_cluster_arn != null ? 1 : 0
  depends_on = [aws_iam_role.role_for_msk]
  name       = "secrets_policy"
  role       = aws_iam_role.role_for_msk[count.index].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = local.api_key_is_arn ? [var.api_key] : [aws_secretsmanager_secret.coralogix_secret[0].arn]
      },
    ]
  })
}

resource "aws_iam_role_policy" "destination_policy" {
  for_each = {
    for key, integration_info in var.integration_info != null ? var.integration_info : local.integration_info : key => integration_info
    if var.notification_email != null && var.msk_cluster_arn != null
  }
  name = "destination_policy"
  role = aws_iam_role.role_for_msk[0].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["sns:publish"]
        Effect   = "Allow",
        Resource = [aws_sns_topic.this[each.key].arn]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "msk-role-policy-attach" {
  count      = var.msk_cluster_arn != null ? 1 : 0
  role       = aws_iam_role.role_for_msk[0].name
  policy_arn = data.aws_iam_policy.AWSLambdaMSKExecutionRole.arn
}

resource "aws_lambda_event_source_mapping" "msk_event_mapping" {
  for_each          = var.msk_topic_name != null ? toset(var.msk_topic_name) : toset([])
  event_source_arn  = var.msk_cluster_arn
  depends_on        = [module.lambda]
  function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  starting_position = "LATEST"
  topics            = [each.value]
}
