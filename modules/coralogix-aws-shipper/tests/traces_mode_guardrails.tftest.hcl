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

  # The S3 and SNS runs below reach resources that build a lambda permission from these
  # ARNs before the precondition is reported; the default mock returns "".
  mock_data "aws_s3_bucket" {
    defaults = {
      arn = "arn:aws:s3:::test-bucket"
    }
  }

  mock_data "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:eu-west-1:123456789012:test-topic"
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

run "rejects_an_s3_trigger" {
  command = plan

  variables {
    s3_bucket_name = "test-bucket"
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_an_sns_trigger" {
  command = plan

  variables {
    sns_topic_name = "test-topic"
    # Unrelated pre-existing bug: aws_sns_topic_policy.test is created for a CloudWatch
    # integration while data.aws_iam_policy_document.topic is gated on is_s3_integration,
    # so the plan fails on an index before the precondition is reported.
    create_sns_topic_policy = false
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_direct_delivery_without_an_api_key" {
  command = plan

  variables {
    api_key = ""
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "accepts_a_collector_without_an_api_key" {
  command = plan

  variables {
    api_key       = ""
    otlp_endpoint = "http://collector.internal:4317"
  }
}

run "rejects_a_custom_region_without_a_domain" {
  command = plan

  variables {
    coralogix_region = "Custom"
    custom_domain    = ""
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "accepts_a_custom_region_with_a_domain" {
  command = plan

  variables {
    coralogix_region = "Custom"
    custom_domain    = "cx123.coralogix.com"
  }
}

# The lambda takes INTEGRATION_TYPE from the integration entry, so the guard has to read
# local.integration_info rather than var.integration_type.
run "rejects_a_non_cloudwatch_integration_info_entry" {
  command = plan

  variables {
    integration_type = "CloudWatch"
    integration_info = {
      integration = {
        application_name = "tf-traces-e2e"
        subsystem_name   = "aws-spans"
        integration_type = "S3"
        s3_bucket_name   = "test-bucket"
        api_key          = "test-api-key"
      }
    }
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

# subnet_ids means "run in a VPC", not "no public egress" - a NAT gateway reaches the
# Coralogix ingress, and the module does not restrict direct OTLP logs either.
run "accepts_a_vpc_deployment_without_a_collector" {
  command = plan

  variables {
    subnet_ids         = ["subnet-0123456789abcdef0"]
    security_group_ids = ["sg-0123456789abcdef0"]
  }
}
