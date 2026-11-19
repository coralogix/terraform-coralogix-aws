# GovCloud loads the Lambda processor from the distribution buckets
# (coralogix-public-artifacts-<region>), which hold the FIPS build under the plain key
# from 0.1.19 on. Unset deploys the partition's default.

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  coralogix_region = "EU1"
  firehose_stream  = "test-stream"
  api_key          = "cxtp_test"
}

run "govcloud_unset_deploys_the_default_from_the_distribution_bucket" {
  command = plan

  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }
  override_data {
    target = data.aws_region.current_region
    values = { id = "us-gov-east-1" }
  }

  assert {
    condition     = aws_lambda_function.lambda_processor[0].s3_bucket == "coralogix-public-artifacts-us-gov-east-1"
    error_message = "GovCloud loads from the distribution bucket in its own region."
  }
  assert {
    condition     = aws_lambda_function.lambda_processor[0].s3_key == "firehose-metrics-transformer-${local.lambda_processor_govcloud_default}.zip"
    error_message = "Unset in GovCloud deploys the GovCloud default under the plain key (the bucket holds only the FIPS build)."
  }
}

run "govcloud_pin_from_0_1_19_is_accepted" {
  command = plan

  variables {
    lambda_processor_version = "0.1.20"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }

  assert {
    condition     = aws_lambda_function.lambda_processor[0].s3_key == "firehose-metrics-transformer-0.1.20.zip"
    error_message = "A GovCloud pin of 0.1.19 or later loads that version."
  }
}

run "govcloud_pin_below_0_1_19_is_rejected" {
  command = plan

  variables {
    lambda_processor_version = "0.1.18"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }

  expect_failures = [terraform_data.govcloud_version_guardrail]
}

run "govcloud_custom_bucket_is_stocked_from_the_distribution_bucket" {
  command = plan

  variables {
    custom_s3_bucket = "customer-owned-bucket"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }

  assert {
    condition     = aws_lambda_function.lambda_processor[0].s3_bucket == "customer-owned-bucket"
    error_message = "custom_s3_bucket still overrides where the function loads from."
  }
  assert {
    condition     = local.lambda_processor_source_url == "https://coralogix-public-artifacts-us-gov-west-1.s3.us-gov-west-1.amazonaws.com"
    error_message = "A GovCloud custom bucket is stocked from the distribution bucket, which only holds the FIPS build."
  }
  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.key == "firehose-metrics-transformer-${local.lambda_processor_govcloud_default}.zip"
    error_message = "The copy stages the key the function loads."
  }
}

run "commercial_unset_deploys_the_commercial_default" {
  command = plan

  override_data {
    target = data.aws_partition.current
    values = { partition = "aws" }
  }
  override_data {
    target = data.aws_region.current_region
    values = { id = "eu-west-1" }
  }

  assert {
    condition     = aws_lambda_function.lambda_processor[0].s3_bucket == "coralogix-serverless-repo-eu-west-1"
    error_message = "Commercial keeps coralogix-serverless-repo-<region>."
  }
  assert {
    condition     = aws_lambda_function.lambda_processor[0].s3_key == "firehose-metrics-transformer-${local.lambda_processor_commercial_default}.zip"
    error_message = "Commercial deploys the commercial default."
  }
}

run "commercial_custom_bucket_is_stocked_from_the_commercial_bucket" {
  command = plan

  variables {
    custom_s3_bucket         = "customer-owned-bucket"
    lambda_processor_version = "0.1.18"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws" }
  }

  assert {
    condition     = local.lambda_processor_source_url == "https://coralogix-serverless-repo-eu-west-1.s3.eu-west-1.amazonaws.com"
    error_message = "Commercial custom buckets are stocked from the commercial bucket, as before."
  }
}

# Disabling the processor while keeping a custom bucket and an old pin must not stage
# anything: the new key for that pin isn't in the distribution bucket, so a copy would
# fail the apply for a processor nobody wants.
run "govcloud_disabled_processor_stages_nothing" {
  command = plan

  variables {
    custom_s3_bucket         = "customer-owned-bucket"
    lambda_processor_version = "0.1.18"
    lambda_processor_enable  = false
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }

  assert {
    condition     = length(null_resource.s3_bucket_copy) == 0
    error_message = "A disabled processor must not stage an artifact."
  }
  assert {
    condition     = length(aws_lambda_function.lambda_processor) == 0
    error_message = "No processor Lambda when it is disabled."
  }
  assert {
    condition     = length(terraform_data.govcloud_version_guardrail) == 0
    error_message = "The version guard only applies to an enabled processor."
  }
}
