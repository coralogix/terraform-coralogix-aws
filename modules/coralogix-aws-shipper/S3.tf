resource "aws_s3_bucket_notification" "lambda_notification" {
  count  = local.is_s3_integration && local.sns_enable != true  && var.sqs_name == null? 1 : 0
  depends_on = [ module.lambda ]
  bucket = data.aws_s3_bucket.this[0].bucket
  dynamic "lambda_function" {
    for_each = var.log_info != null ? var.log_info : local.log_info
    iterator = log_info #why do i need this line?
    content {
      lambda_function_arn = module.lambda[log_info.key].lambda_function_arn #maybe need to use each.key
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = log_info.value.s3_key_prefix != null || (log_info.value.integration_type != "CloudTrail" && log_info.value.integration_type != "VpcFlow") ? log_info.value.s3_key_prefix : "AWSLogs/"
      filter_suffix       = (log_info.value.integration_type != "CloudTrail" && log_info.value.integration_type != "VpcFlow") || log_info.value.s3_key_suffix != null ? log_info.value.s3_key_suffix : lookup(local.s3_suffix_map, log_info.value.integration_type)
    }
  # lambda_function {
  #   lambda_function_arn = module.lambda.lambda_function_arn
  #   events              = ["s3:ObjectCreated:*"]
  #   filter_prefix       = var.s3_key_prefix != null || (var.integration_type != "CloudTrail" && var.integration_type != "VpcFlow") ? var.s3_key_prefix : "AWSLogs/"
  #   filter_suffix       = (var.integration_type != "CloudTrail" && var.integration_type != "VpcFlow") || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(local.s3_suffix_map, var.integration_type)
  # }
  }
}