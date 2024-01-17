resource "aws_s3_bucket_notification" "topic_notification" {
  count  = local.sns_enable == true && (var.integration_type == "S3" || var.integration_type == "CloudTrail" ) ? 1 : 0
  bucket = data.aws_s3_bucket.this[0].bucket
  topic {
    topic_arn     = data.aws_sns_topic.sns_topic[0].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_key_prefix != null || var.integration_type != "CloudTrail" ? var.s3_key_prefix : "AWSLogs/"
    filter_suffix       = var.integration_type != "CloudTrail" || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(local.s3_suffix_map, var.integration_type)
  }
}

resource "aws_sns_topic" "this" {
  for_each = var.log_info != null ? var.log_info : local.log_info
  name_prefix  = each.value.lambda_name == null ? "${module.locals[each.key].function_name}-Failure" : "${each.value.lambda_name}-Failure"
  display_name = each.value.lambda_name == null ? "${module.locals[each.key].function_name}-Failure" : "${each.value.lambda_name}-Failure"
  tags         = merge(var.tags, module.locals[each.key].tags)
}

resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  count      = local.sns_enable ? 1 : 0
  depends_on = [module.lambda]
  topic_arn  = data.aws_sns_topic.sns_topic[count.index].arn
  protocol   = "lambda"
  endpoint   = module.lambda.integration.lambda_function_arn
}