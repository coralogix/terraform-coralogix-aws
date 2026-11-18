# GovCloud loads the shipper from the distribution buckets (coralogix-public-artifacts-<region>),
# which hold 1.4.23 onward under versioned keys only. Commercial is unchanged.
#
# Assertions read module.lambda's s3_object, the bucket and key the function is created
# with, rather than rebuilding them from the module's locals.

mock_provider "aws" {
  mock_data "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::test-bucket"
    }
  }
}

variables {
  coralogix_region = "EU1"
  integration_type = "S3"
  api_key          = "cxtp_test"
  application_name = "test-app"
  subsystem_name   = "test-sub"
  s3_bucket_name   = "test-bucket"
  cpu_arch         = "arm64"
}

run "govcloud_unpinned_deploys_the_default_release_from_the_distribution_bucket" {
  command = plan

  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }
  override_data {
    target = data.aws_region.this
    values = { id = "us-gov-east-1" }
  }

  assert {
    condition = alltrue([for l in module.lambda :
      l.s3_object.bucket == "coralogix-public-artifacts-us-gov-east-1" && l.s3_object.key == "coralogix-aws-shipper-arm64-1.5.2.zip"
    ])
    error_message = "Unpinned GovCloud must load the default release's versioned key from the distribution bucket in its own region."
  }
}

run "govcloud_pin_from_1_4_23_is_accepted" {
  command = plan

  variables {
    source_code_version = "1.4.23"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }
  override_data {
    target = data.aws_region.this
    values = { id = "us-gov-west-1" }
  }

  assert {
    condition = alltrue([for l in module.lambda :
      l.s3_object.bucket == "coralogix-public-artifacts-us-gov-west-1" && l.s3_object.key == "coralogix-aws-shipper-arm64-1.4.23.zip"
    ])
    error_message = "A GovCloud pin of 1.4.23 or later loads that release from the distribution bucket."
  }
}

run "govcloud_pin_below_1_4_23_is_rejected" {
  command = plan

  variables {
    source_code_version = "1.4.19"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }

  expect_failures = [terraform_data.govcloud_version_guardrail]
}

run "govcloud_custom_bucket_stages_the_default_release_from_the_distribution_bucket" {
  command = plan

  variables {
    custom_s3_bucket = "customer-owned-bucket"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws-us-gov" }
  }

  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.source_bucket == "coralogix-public-artifacts-us-gov-west-1"
    error_message = "A GovCloud custom bucket is stocked from the distribution bucket."
  }
  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.artifact == "coralogix-aws-shipper-arm64-1.5.2.zip"
    error_message = "Unpinned GovCloud stages the default release's versioned key."
  }
  assert {
    condition     = alltrue([for l in module.lambda : l.s3_object.bucket == "customer-owned-bucket"])
    error_message = "custom_s3_bucket still overrides where the function loads from."
  }
}

run "commercial_is_unchanged" {
  command = plan

  variables {
    source_code_version = "1.4.19"
  }
  override_data {
    target = data.aws_partition.current
    values = { partition = "aws" }
  }
  override_data {
    target = data.aws_region.this
    values = { id = "eu-west-1" }
  }

  assert {
    condition = alltrue([for l in module.lambda :
      l.s3_object.bucket == "coralogix-serverless-repo-eu-west-1" && l.s3_object.key == "coralogix-aws-shipper-arm64-1.4.19.zip"
    ])
    error_message = "Commercial keeps coralogix-serverless-repo-<region> and accepts pins below 1.4.23."
  }
}

run "commercial_unpinned_keeps_the_unversioned_key" {
  command = plan

  override_data {
    target = data.aws_partition.current
    values = { partition = "aws" }
  }

  assert {
    condition     = alltrue([for l in module.lambda : l.s3_object.key == "coralogix-aws-shipper.zip"])
    error_message = "Unpinned commercial still tracks the unversioned key."
  }
}
