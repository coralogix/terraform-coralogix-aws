resource "aws_s3_bucket_notification" "sqs_notification" {
  count  = var.sqs_name != null && (var.integration_type == "S3" || var.integration_type == "CloudTrail" ) ? 1 : 0
  bucket = data.aws_s3_bucket.this[0].bucket
  queue {
    queue_arn     = data.aws_sqs_queue.name[0].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_key_prefix != null || var.integration_type != "CloudTrail" ? var.s3_key_prefix : "AWSLogs/"
    filter_suffix       = var.integration_type != "CloudTrail" || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(local.s3_suffix_map, var.integration_type)
  }
}

resource "aws_lambda_event_source_mapping" "sqs" {
  depends_on = [ module.lambda ]
  count = local.is_sqs_integration ? 1 : 0
  event_source_arn = data.aws_sqs_queue.name[0].arn
  function_name    = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  enabled          = true
}

resource "aws_sqs_queue_policy" "sqs_policy" {
  count       = local.is_s3_integration && var.sqs_name != null ? 1 : 0
  queue_url   = data.aws_sqs_queue.name[count.index].id
  policy      = data.aws_iam_policy_document.topic[count.index].json
}