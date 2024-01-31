resource "aws_s3_bucket_notification" "lambda_notification" {
  count      = var.s3_bucket_name != null && local.sns_enable != true && var.sqs_name == null ? 1 : 0
  depends_on = [module.lambda]
  bucket     = data.aws_s3_bucket.this[0].bucket
  dynamic "lambda_function" {
    for_each = var.integration_info != null ? var.integration_info : local.integration_info
    iterator = integration_info
    content {
      lambda_function_arn = module.lambda[integration_info.key].lambda_function_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = integration_info.value.s3_key_prefix != null || (integration_info.value.integration_type != "CloudTrail" && integration_info.value.integration_type != "VpcFlow") ? integration_info.value.s3_key_prefix : "AWSLogs/"
      filter_suffix       = (integration_info.value.integration_type != "CloudTrail" && integration_info.value.integration_type != "VpcFlow") || integration_info.value.s3_key_suffix != null ? integration_info.value.s3_key_suffix : lookup(local.s3_suffix_map, integration_info.value.integration_type)
    }
  }
}