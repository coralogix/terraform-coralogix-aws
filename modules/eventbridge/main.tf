module "locals" {
  source = "../locals_variables"

  integration_type = "None"
  random_string    = "None"
}

locals {
  endpoint_url = var.custom_url != null ? var.custom_url : "https://aws-events.${lookup(module.locals.coralogix_domains, var.coralogix_region, "EU1")}/aws/event"

  tags = {
    terraform-module         = "eventbridge-to-coralogix"
    terraform-module-version = "v0.0.3"
    managed-by               = "coralogix-terraform"
    refactored-by            = "krom-devops-team"
  }
  application_name = var.application_name == null ? "coralogix-${var.eventbridge_stream}" : var.application_name
}

data "aws_caller_identity" "current_identity" {}
data "aws_region" "current_region" {}

resource "aws_iam_policy" "eventbridge_policy" {
  name = var.policy_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = ["events:InvokeApiDestination"],
        Resource = [
          "arn:aws:events:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:api-destination/*"
        ]
      },
    ]
  })
}

resource "aws_iam_role" "eventbridge_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_policy_attachment" {
  policy_arn = aws_iam_policy.eventbridge_policy.arn
  role       = aws_iam_role.eventbridge_role.name
}

/// config the api destination to work with Coralogix ///

resource "aws_cloudwatch_event_connection" "event-connectiong" {
  name               = "coralogixConnection"
  description        = "This is Coralogix connection for Evenbridge"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "x-amz-event-bridge-access-key"
      value = var.private_key
    }
    invocation_http_parameters {
      dynamic "header" {
        for_each = var.additional_headers
        content {
          key             = "cx-application-name"
          value           = local.application_name
          is_value_secret = false
        }
      }
    }
  }
}
resource "aws_cloudwatch_event_api_destination" "api-connection" {
  name                             = "toCoralogix"
  description                      = "EventBridge Api destination to Coralogix"
  invocation_endpoint              = local.endpoint_url
  http_method                      = "POST"
  invocation_rate_limit_per_second = 300
  connection_arn                   = aws_cloudwatch_event_connection.event-connectiong.arn
}

// Connecting between the rule and the api target
resource "aws_cloudwatch_event_target" "my_event_target" {
  event_bus_name = var.eventbridge_stream
  arn            = aws_cloudwatch_event_api_destination.api-connection.arn
  rule           = aws_cloudwatch_event_rule.eventbridge_rule.name
  role_arn       = aws_iam_role.eventbridge_role.arn
}
// Creating Rule for classify the events we want to get

resource "aws_cloudwatch_event_rule" "eventbridge_rule" {
  name           = "eventbridge_rule"
  description    = "Capture the main events"
  event_bus_name = var.eventbridge_stream
  ///A number of services that we think are relevant to monitor, sub-alerts can be changed and classified
  event_pattern = var.detail_type != null ? jsonencode(
    {
      "source" : var.sources
      "detail-type" : var.detail_type
    }) : jsonencode(
    {
      "source" : var.sources
    }
  )
}
