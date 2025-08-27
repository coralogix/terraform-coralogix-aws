resource "aws_s3_bucket_notification" "lambda_notification" {
  for_each   = local.s3_bucket_names != toset([]) && local.sns_enable != true && var.sqs_name == null && var.telemetry_mode != "metrics" && var.s3_notification != false ? data.aws_s3_bucket.this : {}
  depends_on = [module.lambda]
  bucket     = each.value.bucket
  dynamic "lambda_function" {
    for_each = local.integration_info
    iterator = integration_info
    content {
      lambda_function_arn = module.lambda[integration_info.key].lambda_function_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = integration_info.value.s3_key_prefix != null || (integration_info.value.integration_type != "CloudTrail" && integration_info.value.integration_type != "VpcFlow") ? integration_info.value.s3_key_prefix : "AWSLogs/"
      filter_suffix       = (integration_info.value.integration_type != "CloudTrail" && integration_info.value.integration_type != "VpcFlow") || integration_info.value.s3_key_suffix != null ? integration_info.value.s3_key_suffix : lookup(local.s3_suffix_map, integration_info.value.integration_type)
    }
  }
}
