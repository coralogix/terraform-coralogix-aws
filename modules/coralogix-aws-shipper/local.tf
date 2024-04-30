locals {
  s3_suffix_map = {
    CloudTrail = ".json.gz"
    VpcFlow    = ".log.gz"
  }

  sns_enable = var.sns_topic_name != "" ? true : false

  log_groups = {
    for group in var.log_groups : group =>
    length(group) > 100 ? "${substr(replace(group, "/", "_"), 0, 95)}_${substr(sha256(group), 0, 4)}" : replace(group, "/", "_")
  }
  
  log_group_prefix = var.log_group_prefix != null ? {
    # Need to convert the log group prefix to a map so we could use it in the for_each in CloudWatch file
    for group in var.log_group_prefix : group =>
    group
  } : {}

  api_key_is_arn = replace(var.api_key, ":", "") != var.api_key ? true : false

  integration_info = var.integration_info == null ? {
    integration = {
      application_name     = var.application_name
      subsystem_name       = var.subsystem_name
      integration_type     = var.integration_type
      s3_key_prefix        = var.s3_key_prefix
      s3_key_suffix        = var.s3_key_suffix
      newline_pattern      = var.newline_pattern
      blocking_pattern     = var.blocking_pattern
      lambda_name          = var.lambda_name
      lambda_log_retention = var.lambda_log_retention
    }
  } : {}

  is_s3_integration  = var.integration_type == "S3Csv" || var.integration_type == "CloudFront" || var.integration_type == "S3" || var.integration_type == "CloudTrail" || var.integration_type == "VpcFlow" ? true : false
  is_sns_integration = local.sns_enable && (var.integration_type == "S3" || var.integration_type == "Sns" || var.integration_type == "CloudTrail") ? true : false
  is_sqs_integration = var.sqs_name != null && (var.integration_type == "S3" || var.integration_type == "CloudTrail" || var.integration_type == "Sqs") ? true : false

}