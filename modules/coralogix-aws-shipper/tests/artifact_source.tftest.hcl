# Where a custom_s3_bucket is stocked FROM.
#
# GovCloud is a separate partition with its own artifacts, and since shipper 1.4.23 its
# binary is a different build: it pins the NIST-validated AWS-LC FIPS v3 module, where
# the commercial build moved to v4, which NIST has not validated. Staging the commercial
# zip into a GovCloud bucket therefore deploys an unvalidated cryptographic module to a
# FedRAMP workload, which is what these assertions exist to catch.
#
# Every assertion reads null_resource.s3_bucket_copy's triggers, which carry the same
# locals the provisioner interpolates. Rebuilding the expected string from those locals
# would keep passing if the partition branch were removed.

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
  custom_s3_bucket = "customer-owned-bucket"
}

run "commercial_stages_from_the_commercial_bucket" {
  command = plan

  variables {
    cpu_arch = "arm64"
  }

  override_data {
    target = data.aws_partition.current
    values = {
      partition = "aws"
    }
  }

  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.source_bucket == "coralogix-serverless-repo-ap-east-1"
    error_message = "A commercial deployment stages from ap-east-1, the source this module has used since March 2024."
  }
}

run "govcloud_stages_from_the_govcloud_bucket" {
  command = plan

  variables {
    cpu_arch = "arm64"
  }

  override_data {
    target = data.aws_partition.current
    values = {
      partition = "aws-us-gov"
    }
  }

  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.source_bucket == "coralogix-serverless-repo-us-gov-west-1"
    error_message = "A GovCloud deployment must stage the GovCloud build; the commercial artifact carries the unvalidated AWS-LC FIPS v4 module."
  }
}

# The staged object and the one the Lambda loads are the same expression. They were not:
# the copy uploaded the unversioned name unconditionally, so pinning a version alongside
# custom_s3_bucket left the Lambda pointing at a key nothing had staged.
run "the_staged_key_is_the_key_the_lambda_loads" {
  command = plan

  variables {
    cpu_arch            = "x86_64"
    source_code_version = "1.4.23"
  }

  assert {
    condition = alltrue([
      for l in module.lambda :
      l.s3_object.key == null_resource.s3_bucket_copy[0].triggers.artifact
    ])
    error_message = "The copy must stage exactly the object the Lambda reads back out of the custom bucket."
  }

  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.artifact == "coralogix-aws-shipper-x86-64-1.4.23.zip"
    error_message = "A pinned version must stage the versioned key, not the unversioned one."
  }
}

# Changing the pinned version has to change a trigger, or the copy never runs again and
# the custom bucket keeps serving the artifact of the previous version.
run "the_pinned_version_reaches_the_triggers" {
  command = plan

  variables {
    cpu_arch            = "arm64"
    source_code_version = "1.4.19"
  }

  assert {
    condition     = null_resource.s3_bucket_copy[0].triggers.artifact == "coralogix-aws-shipper-arm64-1.4.19.zip"
    error_message = "source_code_version must reach the triggers, so bumping it re-stages the artifact."
  }
}
