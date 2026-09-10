mock_provider "aws" {
  # The mock returns "" for every string, which is not a policy document.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

mock_provider "random" {}

mock_provider "time" {}

variables {
  regex_pattern   = ".*"
  logs_filter     = ""
  destination_arn = "arn:aws:lambda:us-east-1:123456789012:function:cx-shipper"
}

run "lambda_destination_wiring" {
  command = plan

  variables {
    destination_type = "lambda"
  }

  assert {
    condition     = jsondecode(aws_lambda_invocation.trigger_lambda_for_first_time.input).RequestType == "Reconcile"
    error_message = "Lambda Manager 3.0.0 rejects any request type other than Reconcile."
  }

  assert {
    condition     = aws_lambda_invocation.trigger_lambda_for_first_time.lifecycle_scope == "CRUD"
    error_message = "CRUD scope is what runs cleanup on destroy."
  }

  assert {
    # triggers is ForceNew, and replacing a CRUD invocation unsubscribes every
    # managed log group before resubscribing it. The hash belongs in the input.
    condition     = aws_lambda_invocation.trigger_lambda_for_first_time.triggers == null && jsondecode(aws_lambda_invocation.trigger_lambda_for_first_time.input).ConfigHash != ""
    error_message = "The config hash must ride in input, never in triggers."
  }

  assert {
    condition = alltrue([
      for action in [
        "tag:GetResources",
        "logs:DeleteSubscriptionFilter",
        "logs:TagResource",
        "logs:UntagResource",
        "logs:DescribeLogGroups",
        "lambda:AddPermission",
      ] : contains(flatten([for statement in output.lambda_policy_statements : statement.actions]), action)
    ])
    error_message = "The role is missing an action that Lambda Manager 3.0.0 calls."
  }

  assert {
    condition     = !contains(flatten([for statement in output.lambda_policy_statements : statement.actions]), "iam:PassRole")
    error_message = "iam:PassRole is only needed for Firehose destinations."
  }

  assert {
    condition     = output.lambda_package_key == "lambda-manager-3.0.0.zip"
    error_message = "The package must be pinned, or a new Lambda release changes existing deployments."
  }
}

run "firehose_destination_wiring" {
  command = plan

  variables {
    destination_type = "firehose"
    destination_arn  = "arn:aws:firehose:us-east-1:123456789012:deliverystream/cx-logs"
    destination_role = "arn:aws:iam::123456789012:role/cx-firehose"
  }

  assert {
    condition     = contains(flatten([for statement in output.lambda_policy_statements : statement.actions]), "iam:PassRole")
    error_message = "Firehose destinations need iam:PassRole."
  }

  assert {
    condition     = !contains(flatten([for statement in output.lambda_policy_statements : statement.actions]), "lambda:AddPermission")
    error_message = "lambda:AddPermission is only needed for Lambda destinations."
  }
}

run "rejects_empty_regex" {
  command = plan

  variables {
    destination_type = "lambda"
    regex_pattern    = " "
  }

  expect_failures = [var.regex_pattern]
}
