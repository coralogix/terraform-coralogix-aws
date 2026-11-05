# otlp_headers reaches the lambda only on the Collector route, and only then needs a
# shipper that reads OTLP_HEADERS (1.5.0+). Direct routes ignore it at any version.

mock_provider "aws" {
  # The CloudWatch path builds ARNs from these; the default mock returns values the
  # provider's ARN validation rejects before any assertion runs.
  mock_data "aws_cloudwatch_log_group" {
    defaults = {
      arn = "arn:aws:logs:eu-west-1:123456789012:log-group:test-group"
    }
  }

  mock_data "aws_region" {
    defaults = {
      id = "eu-west-1"
    }
  }

  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
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

variables {
  coralogix_region      = "EU1"
  telemetry_mode        = "logs"
  log_export_protocol   = "otlp_grpc"
  otlp_endpoint         = "https://collector.internal:4317"
  integration_type      = "CloudWatch"
  log_groups            = ["test-group"]
  application_name      = "test-application"
  subsystem_name        = "test-subsystem"
  create_execution_role = false
  execution_role_arn    = "arn:aws:iam::123456789012:role/test-role"
  s3_notification       = false
}

run "default_omits_otlp_headers" {
  command = plan

  assert {
    condition     = local.otlp_headers_env == null
    error_message = "OTLP_HEADERS must be omitted when otlp_headers is unset."
  }
}

run "collector_logs_send_headers" {
  command = plan

  variables {
    otlp_headers = "x-api-key=secret;tenant=acme"
  }

  assert {
    condition     = nonsensitive(local.otlp_headers_env == "x-api-key=secret;tenant=acme")
    error_message = "Collector logs must pass otlp_headers through as OTLP_HEADERS."
  }
}

run "collector_traces_send_headers" {
  command = plan

  variables {
    telemetry_mode   = "traces"
    log_groups       = ["aws/spans"]
    application_name = "aws-spans"
    subsystem_name   = "traces"
    otlp_headers     = "x-api-key=secret"
  }

  assert {
    condition     = nonsensitive(local.otlp_headers_env == "x-api-key=secret")
    error_message = "Collector traces must pass otlp_headers through as OTLP_HEADERS."
  }
}

run "pinned_1_5_0_passes" {
  command = plan

  variables {
    otlp_headers        = "x-api-key=secret"
    source_code_version = "1.5.0"
  }

  assert {
    condition     = nonsensitive(local.otlp_headers_env == "x-api-key=secret")
    error_message = "A 1.5.0 pin must accept otlp_headers."
  }
}

run "collector_logs_older_pin_fails" {
  command = plan

  variables {
    otlp_headers        = "x-api-key=secret"
    source_code_version = "1.4.23"
  }

  expect_failures = [terraform_data.otlp_headers_guardrails]
}

run "collector_traces_older_pin_fails" {
  command = plan

  variables {
    telemetry_mode      = "traces"
    log_groups          = ["aws/spans"]
    application_name    = "aws-spans"
    subsystem_name      = "traces"
    otlp_headers        = "x-api-key=secret"
    source_code_version = "1.4.23"
  }

  expect_failures = [terraform_data.otlp_headers_guardrails]
}

run "direct_route_ignores_headers_with_older_pin" {
  command = plan

  variables {
    otlp_endpoint       = ""
    api_key             = "test-api-key"
    otlp_headers        = "x-api-key=secret"
    source_code_version = "1.4.23"
  }

  assert {
    condition     = local.otlp_headers_env == null
    error_message = "Direct Coralogix OTLP must not receive OTLP_HEADERS."
  }
}

run "rest_route_ignores_headers_with_older_pin" {
  command = plan

  variables {
    log_export_protocol = "coralogix_rest"
    api_key             = "test-api-key"
    otlp_headers        = "x-api-key=secret"
    source_code_version = "1.4.23"
  }

  assert {
    condition     = local.otlp_headers_env == null
    error_message = "Coralogix REST must not receive OTLP_HEADERS."
  }
}
