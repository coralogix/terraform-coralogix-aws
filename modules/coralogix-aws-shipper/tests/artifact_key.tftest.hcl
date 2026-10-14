# The published artifact keys spell the architecture "x86-64" while var.cpu_arch is
# "x86_64", and the unversioned arm64 object carries no architecture at all.
#
# Every assertion reads module.lambda's s3_object.key, which is the value the child
# module passes to aws_lambda_function.s3_key -- not a string rebuilt from the same
# locals the module uses. Reconstructing the expectation would keep passing if the key
# expression were reverted, which is the regression this file exists to catch.

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
}

run "arm64_unversioned_carries_no_architecture" {
  command = plan

  variables {
    cpu_arch = "arm64"
  }

  assert {
    condition     = alltrue([for l in module.lambda : l.s3_object.key == "coralogix-aws-shipper.zip"])
    error_message = "The unversioned arm64 artifact is published without an architecture segment."
  }
}

run "x86_unversioned_uses_the_hyphenated_spelling" {
  command = plan

  variables {
    cpu_arch = "x86_64"
  }

  assert {
    condition     = alltrue([for l in module.lambda : l.s3_object.key == "coralogix-aws-shipper-x86-64.zip"])
    error_message = "cpu_arch is \"x86_64\" but the published keys spell it \"x86-64\"."
  }
}

run "arm64_versioned_matches_the_published_name" {
  command = plan

  variables {
    cpu_arch            = "arm64"
    source_code_version = "1.4.16"
  }

  assert {
    condition     = alltrue([for l in module.lambda : l.s3_object.key == "coralogix-aws-shipper-arm64-1.4.16.zip"])
    error_message = "The pinned arm64 key must match the published object name."
  }
}

run "x86_versioned_does_not_repeat_the_architecture" {
  command = plan

  variables {
    cpu_arch            = "x86_64"
    source_code_version = "1.4.16"
  }

  # Previously resolved coralogix-aws-shipper-x86-64-x86_64-1.4.16.zip, which has never
  # been published in any region.
  assert {
    condition     = alltrue([for l in module.lambda : l.s3_object.key == "coralogix-aws-shipper-x86-64-1.4.16.zip"])
    error_message = "The pinned x86_64 key must match the published object name."
  }

  assert {
    condition     = alltrue([for l in module.lambda : !strcontains(l.s3_object.key, "x86_64")])
    error_message = "The artifact key must never contain the cpu_arch spelling \"x86_64\"."
  }
}
