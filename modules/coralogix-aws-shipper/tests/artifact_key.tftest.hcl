# The published artifact keys spell the architecture "x86-64" while var.cpu_arch is
# "x86_64", and the unversioned arm64 object carries no architecture at all. Pinning all
# four shapes here because a wrong key is only visible as a NoSuchKey at Lambda creation,
# which reads like a missing artifact rather than a module bug.

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

run "arm64_unversioned_has_no_architecture" {
  command = plan

  variables {
    cpu_arch = "arm64"
  }

  assert {
    condition     = local.artifact_arch == "arm64"
    error_message = "arm64 artifacts are published under the \"arm64\" spelling."
  }
}

run "x86_uses_the_hyphenated_spelling" {
  command = plan

  variables {
    cpu_arch = "x86_64"
  }

  assert {
    condition     = local.artifact_arch == "x86-64"
    error_message = "cpu_arch is \"x86_64\" but the published keys spell it \"x86-64\"; a key built from cpu_arch does not exist."
  }
}

run "x86_versioned_key_is_not_doubled" {
  command = plan

  variables {
    cpu_arch            = "x86_64"
    source_code_version = "1.4.16"
  }

  # The previous expression appended cpu_arch to a name that already carried the
  # architecture, yielding coralogix-aws-shipper-x86-64-x86_64-1.4.16.zip.
  assert {
    condition     = !strcontains("coralogix-aws-shipper-${local.artifact_arch}-1.4.16.zip", "x86_64")
    error_message = "The x86 versioned key must not contain the cpu_arch spelling."
  }

  assert {
    condition     = "coralogix-aws-shipper-${local.artifact_arch}-1.4.16.zip" == "coralogix-aws-shipper-x86-64-1.4.16.zip"
    error_message = "The x86 versioned key must match the published object name."
  }
}

run "arm64_versioned_key_matches_published_name" {
  command = plan

  variables {
    cpu_arch            = "arm64"
    source_code_version = "1.4.16"
  }

  assert {
    condition     = "coralogix-aws-shipper-${local.artifact_arch}-1.4.16.zip" == "coralogix-aws-shipper-arm64-1.4.16.zip"
    error_message = "The arm64 versioned key must match the published object name."
  }
}
