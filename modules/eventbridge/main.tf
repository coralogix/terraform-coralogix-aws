
provider "aws" {
  region = data.aws_region.current_region.name
}
locals {
  endpoint_url = {
    "us" = {
      url = "https://aws-events.coralogix.us/aws/event"
    }
    "singapore" = {
      url = "https://aws-events.coralogixsg.com/aws/event"
    }
    "ireland" = {
      url = "https://aws-events.coralogix.com/aws/event"
    }
    "india" = {
      url = "https://aws-events.coralogix.in/aws/event"
    }
    "stockholm" = {
      url = "https://aws-events.eu2.coralogix.com/aws/event"
    }
  }

    tags = {
    terraform-module         = "eventbridge-to-coralogix"
    terraform-module-version = "v0.0.1"
    managed-by               = "coralogix-terraform"
  }
  application_name = var.application_name == null ? "coralogix-${var.eventbridge_stream}" : var.application_name
}

data "aws_caller_identity" "current_identity" {}
data "aws_region" "current_region" {}

resource "aws_iam_policy" "eventbridge_policy" {
  name        = "EventBridge_policy"
  policy      = jsonencode({
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
      value =var.private_key
    }
  }
}
resource "aws_cloudwatch_event_api_destination" "api-connection" {
  name                             = "toCoralogix"
  description                      = "EventBridge Api destination to Coralogix"
  invocation_endpoint              = local.endpoint_url[var.coralogix_region].url
  http_method                      = "POST"
  invocation_rate_limit_per_second = 300
  connection_arn                   = aws_cloudwatch_event_connection.event-connectiong.arn
}

// Connecting between the rule and the api target
resource "aws_cloudwatch_event_target" "my_event_target" {
  arn  = aws_cloudwatch_event_api_destination.api-connection.arn
  rule = aws_cloudwatch_event_rule.eventbridge_rule.name
  role_arn = aws_iam_role.eventbridge_role.arn
}
// Creating Rule for classify the events we want to get

resource "aws_cloudwatch_event_rule" "eventbridge_rule" {
  name        = "eventbridge_rule"
  description = "Capture the main events"
///A number of services that we think are relevant to monitor, sub-alerts can be changed and classified
  event_pattern = jsonencode(
{
  "source": var.sources
})
}
