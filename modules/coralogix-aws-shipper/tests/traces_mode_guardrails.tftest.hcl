# The traces handler reads CloudWatch Logs events from aws/spans only. Kinesis, Kafka,
# MSK and the DLQ mapping are created from their own variables without consulting
# telemetry_mode, so each would attach an event source whose deliveries fail and retry.
# These runs pin that the guardrails refuse those combinations at plan time.

mock_provider "aws" {
  # The CloudWatch path reads the target log group; the default mock returns "" for
  # every string, which is not a usable ARN.
  mock_data "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:eu-west-1:123456789012:log-group:aws/spans"
    }
  }
}

mock_provider "external" {}

mock_provider "local" {}

mock_provider "null" {}

mock_provider "random" {}

variables {
  coralogix_region      = "EU1"
  api_key               = "test-api-key"
  telemetry_mode        = "traces"
  integration_type      = "CloudWatch"
  log_groups            = ["aws/spans"]
  application_name      = "aws-spans"
  subsystem_name        = "traces"
  create_execution_role = false
  execution_role_arn    = "arn:aws:iam::123456789012:role/test-role"
  s3_notification       = false
}

run "accepts_a_valid_traces_deployment" {
  command = plan
}

run "rejects_a_non_cloudwatch_integration" {
  command = plan

  variables {
    integration_type = "EcrScan"
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_a_log_group_other_than_aws_spans" {
  command = plan

  variables {
    log_groups = ["my-application-logs"]
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_a_kinesis_trigger" {
  command = plan

  variables {
    kinesis_stream_name = "some-stream"
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_the_dead_letter_queue" {
  command = plan

  variables {
    enable_dlq    = true
    dlq_s3_bucket = "test-dlq-bucket"
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_privatelink_without_a_collector" {
  command = plan

  variables {
    subnet_ids = ["subnet-0123456789abcdef0"]
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "accepts_privatelink_with_a_collector" {
  command = plan

  variables {
    subnet_ids    = ["subnet-0123456789abcdef0"]
    otlp_endpoint = "http://collector.internal:4317"
  }
}
