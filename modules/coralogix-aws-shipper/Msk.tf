resource "aws_iam_role" "role_for_all" {
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

resource "aws_iam_role_policy_attachment" "msk-role-policy-attach" {
  count = var.msk_cluster_arn != null ? 1 : 0
  role  = aws_iam_role.role_for_all[0].name
  #   for_each = toset([data.aws_iam_policy.AWSLambdaMSKExecutionRole.arn,
  #     data.aws_iam_policy.SecretsManagerReadWrite.arn,
  #     data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
  #   ])
  policy_arn = data.aws_iam_policy.AWSLambdaMSKExecutionRole.arn
}

resource "aws_lambda_event_source_mapping" "msk_event_mapping" {
  count             = var.msk_cluster_arn != null ? 1 : 0
  event_source_arn  = var.msk_cluster_arn
  depends_on        = [module.lambda]
  function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  starting_position = "LATEST"
  topics            = [var.msk_topic_name]
}

# resource "aws_lambda_event_source_mapping" "msk_lambda_notification" {
#     count = var.msk_cluster_arn != null ? 1 : 0
#     depends_on = [ module.lambda ]
#     event_source_arn  = var.msk_cluster_arn
#     function_name     = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
#     topics            = [var.msk_topic_name]
#     starting_position = "TRIM_HORIZON"
# }