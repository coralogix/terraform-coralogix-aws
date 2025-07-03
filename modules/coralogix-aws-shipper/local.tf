locals {
  s3_suffix_map = {
    CloudTrail = ".json.gz"
    VpcFlow    = ".log.gz"
  }

  sns_enable = var.sns_topic_name != null ? true : false

  log_groups = {
    for group in var.log_groups : group =>
    length(group) > 100 ? "${substr(replace(group, "/", "_"), 0, 95)}_${substr(sha256(group), 0, 4)}" : replace(group, "/", "_")
  }

  log_group_prefix = var.log_group_prefix != null ? {
    # Need to convert the log group prefix to a map so we could use it in the for_each in CloudWatch file
    for group in var.log_group_prefix : group =>
    group
  } : {}

  api_key_is_arn = replace(nonsensitive(var.api_key), ":", "") != nonsensitive(var.api_key) ? true : false

  sensitive_integration_info = var.integration_info == null ? {
    integration = {
      s3_bucket_name                   = var.s3_bucket_name
      application_name                 = var.application_name
      subsystem_name                   = var.subsystem_name
      integration_type                 = var.integration_type
      s3_key_prefix                    = var.s3_key_prefix
      s3_key_suffix                    = var.s3_key_suffix
      newline_pattern                  = var.newline_pattern
      blocking_pattern                 = var.blocking_pattern
      lambda_name                      = var.lambda_name
      lambda_log_retention             = var.lambda_log_retention
      api_key                          = var.api_key
      store_api_key_in_secrets_manager = var.store_api_key_in_secrets_manager
    }
    } : var.api_key == "" ? var.integration_info : {
    for k, v in var.integration_info : k => {
      s3_bucket_name                   = v.s3_bucket_name
      s3_key_prefix                    = v.s3_key_prefix
      s3_key_suffix                    = v.s3_key_suffix
      application_name                 = v.application_name
      subsystem_name                   = v.subsystem_name
      integration_type                 = v.integration_type
      lambda_name                      = v.lambda_name
      newline_pattern                  = v.newline_pattern
      blocking_pattern                 = v.blocking_pattern
      lambda_log_retention             = v.lambda_log_retention
      api_key                          = v.api_key != null ? v.api_key : var.api_key
      store_api_key_in_secrets_manager = v.store_api_key_in_secrets_manager
    }
  }
  integration_info = try(nonsensitive(local.sensitive_integration_info), local.sensitive_integration_info)

  is_s3_integration  = var.integration_type == "S3Csv" || var.integration_type == "CloudFront" || var.integration_type == "S3" || var.integration_type == "CloudTrail" || var.integration_type == "VpcFlow" ? true : false
  is_sns_integration = local.sns_enable && (var.integration_type == "S3" || var.integration_type == "Sns" || var.integration_type == "CloudTrail") ? true : false
  is_sqs_integration = var.sqs_name != null && (var.integration_type == "S3" || var.integration_type == "CloudTrail" || var.integration_type == "Sqs") ? true : false

  arn_prefix      = "arn:${data.aws_partition.current.partition}"
  s3_bucket_names = var.s3_bucket_name != null ? toset(split(",", var.s3_bucket_name)) : toset([])
}
