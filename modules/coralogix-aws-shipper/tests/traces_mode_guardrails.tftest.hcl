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

  # The log_group_prefix run builds an ARN from these; random mock values are rejected
  # by the provider's ARN validation before the precondition is reported.
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

  # local.arn_prefix is built from this; a random mock value fails the provider's
  # partition validation before any precondition is reported.
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

  # The preconditions reject every input that would otherwise reach the gating, so
  # without these asserts the whole !local.is_traces mechanism is untested - removing it
  # from all seven files leaves the suite green.
  assert {
    condition = (
      length(aws_lambda_event_source_mapping.example) == 0 &&
      length(aws_lambda_event_source_mapping.kafka) == 0 &&
      length(aws_lambda_event_source_mapping.msk_event_mapping) == 0 &&
      length(aws_lambda_event_source_mapping.sqs) == 0 &&
      length(aws_lambda_event_source_mapping.dlq_sqs) == 0
    )
    error_message = "no event source mapping may exist in traces mode"
  }

  assert {
    condition = (
      length(aws_sns_topic_subscription.lambda_sns_subscription) == 0 &&
      length(aws_s3_bucket_notification.lambda_notification) == 0 &&
      length(aws_s3_bucket_notification.topic_notification) == 0 &&
      length(aws_s3_bucket_notification.sqs_notification) == 0
    )
    error_message = "no notification or subscription may exist in traces mode"
  }

  assert {
    condition = (
      length(aws_cloudwatch_event_rule.EventBridgeRule) == 0 &&
      length(aws_cloudwatch_event_target.EventBridgeRuleTarget) == 0
    )
    error_message = "no EventBridge trigger may exist in traces mode"
  }

  # The aws/spans trigger itself must still be created.
  assert {
    condition     = length(aws_cloudwatch_log_subscription_filter.this) == 1
    error_message = "the aws/spans subscription filter must be created"
  }

  # E3: without these the env wiring could be reverted to master and this still passes.
  assert {
    condition     = local.use_coralogix_otlp_traces && !local.use_collector_otlp_traces
    error_message = "an empty otlp_endpoint must select the direct Coralogix route"
  }

  assert {
    condition     = local.needs_coralogix_api_key
    error_message = "direct traces must require an api key"
  }
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

run "rejects_a_kafka_trigger" {
  command = plan

  variables {
    kafka_brokers = "b-1.example:9092"
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_an_msk_topic" {
  command = plan

  variables {
    msk_topic_name = ["test-topic"]
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

# msk_cluster_arn attaches the MSK execution role without creating any trigger, so it
# reaches neither the gating nor the other precondition members.
run "rejects_an_msk_cluster_arn" {
  command = plan

  variables {
    msk_cluster_arn = "arn:aws:kafka:eu-west-1:123456789012:cluster/test/abc-1"
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

  assert {
    condition     = local.use_collector_otlp_traces && !local.use_coralogix_otlp_traces
    error_message = "a non-empty otlp_endpoint must select the collector route"
  }

  assert {
    condition     = !local.needs_coralogix_api_key
    error_message = "the collector route must not require an api key"
  }
}

run "rejects_an_sqs_trigger" {
  command = plan

  variables {
    sqs_name = "test-queue"
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

run "rejects_a_log_group_prefix" {
  command = plan

  variables {
    log_group_prefix = ["my-app-"]
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
}

# Sqs.tf and Ecr.tf read the top-level integration_type.
run "rejects_a_trigger_producing_top_level_integration_type" {
  command = plan

  variables {
    integration_type = "EcrScan"
    integration_info = {
      integration = {
        application_name = "tf-traces-e2e"
        subsystem_name   = "aws-spans"
        integration_type = "CloudWatch"
        api_key          = "test-api-key"
      }
    }
  }

  expect_failures = [terraform_data.traces_mode_guardrails]
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

# CloudWatch.tf addresses the entry by the literal key "integration" and api_key_is_arn
# reads only the top-level api_key, so integration_info is refused outright.
run "rejects_integration_info" {
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
