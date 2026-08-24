mock_provider "aws" {
  mock_data "aws_s3_bucket" {
    defaults = {
      arn    = "arn:aws:s3:::test-bucket"
      bucket = "test-bucket"
      id     = "test-bucket"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }
}

mock_provider "external" {}

mock_provider "local" {}

mock_provider "null" {}

mock_provider "random" {}

# PR #334 / CDS-3168: Default path — module creates the firehose role with
# name_prefix (not a hardcoded name) and no RoleArn parameter in the Lambda
# processor.
run "module_creates_firehose_role_with_name_prefix" {
  command = plan

  variables {
    coralogix_region      = "EU1"
    api_key               = "test-api-key"
    application_name      = "test-app"
    subsystem_name        = "test-sub"
    s3_bucket_name        = "test-bucket"
    integration_type      = "S3"
    lambda_name           = "test-function"
    telemetry_mode        = "metrics"
    create_execution_role = false
    execution_role_arn    = "arn:aws:iam::123456789012:role/test-role"
    s3_notification       = false
  }

  assert {
    condition     = aws_iam_role.s3_firehose_metrics_role[0].name_prefix == "s3-firehose-metrics-"
    error_message = "Firehose metrics role should use name_prefix to avoid name collisions across regions/accounts"
  }

  assert {
    condition     = aws_iam_role_policy.s3_firehose_metrics_policy[0].name_prefix == "s3-firehose-metrics-policy-"
    error_message = "Firehose metrics policy should use name_prefix to avoid name collisions"
  }

  assert {
    condition = one([
      for statement in jsondecode(aws_iam_role_policy.s3_firehose_metrics_policy[0].policy).Statement :
      statement.Resource if contains(statement.Action, "lambda:InvokeFunction")
    ]) == ["arn:aws:lambda:*:*:function:test-function"]
    error_message = "Firehose IAM policy should use a function ARN without the $LATEST suffix"
  }

  assert {
    condition = (
      length(aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].extended_s3_configuration[0].processing_configuration[0].processors[0].parameters) == 1 &&
      alltrue([
        for parameter in aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].extended_s3_configuration[0].processing_configuration[0].processors[0].parameters :
        parameter.parameter_name == "LambdaArn"
      ])
    )
    error_message = "Firehose Lambda processor should contain only the LambdaArn parameter"
  }
}

# PR #334 / CDS-3168: BYO role path — create_firehose_role=false +
# firehose_role_arn set. Module must skip role creation and use the provided
# ARN for the Firehose delivery stream.
run "byo_role_skips_creation_and_uses_provided_arn" {
  command = plan

  variables {
    coralogix_region      = "EU1"
    api_key               = "test-api-key"
    application_name      = "test-app"
    subsystem_name        = "test-sub"
    s3_bucket_name        = "test-bucket"
    integration_type      = "S3"
    telemetry_mode        = "metrics"
    create_execution_role = false
    execution_role_arn    = "arn:aws:iam::123456789012:role/test-role"
    s3_notification       = false
    create_firehose_role  = false
    firehose_role_arn     = "arn:aws:iam::123456789012:role/byo-firehose-role"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].extended_s3_configuration[0].role_arn == "arn:aws:iam::123456789012:role/byo-firehose-role"
    error_message = "Firehose delivery stream should use the BYO role ARN when firehose_role_arn is provided"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].extended_s3_configuration[0].s3_backup_configuration[0].role_arn == "arn:aws:iam::123456789012:role/byo-firehose-role"
    error_message = "Firehose S3 backup configuration should also use the BYO role ARN"
  }

  assert {
    condition     = length(aws_iam_role.s3_firehose_metrics_role) == 0
    error_message = "Module should not create a Firehose IAM role when create_firehose_role is false"
  }

  assert {
    condition     = length(aws_iam_role_policy.s3_firehose_metrics_policy) == 0
    error_message = "Module should not create a Firehose IAM policy when create_firehose_role is false"
  }
}

# PR #334 / CDS-3168: Precedence — firehose_role_arn takes priority over
# create_firehose_role=true. Even when create_firehose_role is true, providing
# firehose_role_arn must skip role creation and use the provided ARN.
run "firehose_role_arn_overrides_create_flag" {
  command = plan

  variables {
    coralogix_region      = "EU1"
    api_key               = "test-api-key"
    application_name      = "test-app"
    subsystem_name        = "test-sub"
    s3_bucket_name        = "test-bucket"
    integration_type      = "S3"
    telemetry_mode        = "metrics"
    create_execution_role = false
    execution_role_arn    = "arn:aws:iam::123456789012:role/test-role"
    s3_notification       = false
    create_firehose_role  = true
    firehose_role_arn     = "arn:aws:iam::123456789012:role/byo-firehose-role"
  }

  assert {
    condition     = aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].extended_s3_configuration[0].role_arn == "arn:aws:iam::123456789012:role/byo-firehose-role"
    error_message = "firehose_role_arn should take precedence over create_firehose_role=true"
  }

  assert {
    condition     = length(aws_iam_role.s3_firehose_metrics_role) == 0
    error_message = "Module should not create a Firehose IAM role when firehose_role_arn is provided"
  }

  assert {
    condition     = length(aws_iam_role_policy.s3_firehose_metrics_policy) == 0
    error_message = "Module should not create a Firehose IAM policy when firehose_role_arn is provided"
  }
}
