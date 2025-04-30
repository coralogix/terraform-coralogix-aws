data "aws_region" "this" {}

data "aws_caller_identity" "current" {}

locals {
  log_groups_prefix_string = join(",", var.log_group_permissions_prefix)
}

resource "random_string" "this" {
  length  = 12
  special = false
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "6.5.0"
  function_name          = "serverlessrepo-Coralogix-Lambda-Man-LambdaFunction-${random_string.this.result}"
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.12"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    LOGS_FILTER                 = var.logs_filter
    REGEX_PATTERN               = var.regex_pattern
    DESTINATION_ARN             = var.destination_arn
    DESTINATION_ROLE            = var.destination_role
    DESTINATION_TYPE            = var.destination_type
    SCAN_OLD_LOGGROUPS          = var.scan_old_loggroups
    LOG_GROUP_PERMISSION_PREFIX = local.log_groups_prefix_string
    DISABLE_ADD_PERMISSION = var.disable_add_permission
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "lambda-manager.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "serverlessrepo-Coralogix-Lambda-Man-${random_string.this.result}-Role"
  role_description                        = "Role for serverlessrepo-Coralogix-Lambda-Man-${random_string.this.result} Lambda Function."
  create_current_version_allowed_triggers = false
  attach_policy_statements                = true
  policy_statements = {
    CXLambdaUpdateConfig = {
      effect    = "Allow"
      actions   = ["lambda:UpdateFunctionConfiguration", "lambda:GetFunctionConfiguration", "lambda:AddPermission"]
      resources = ["arn:aws:lambda:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:function:*"]
    },
    CXLogConfig = {
      effect    = "Allow"
      actions   = ["logs:PutSubscriptionFilter", "logs:DescribeLogGroups", "logs:DescribeSubscriptionFilters"]
      resources = ["arn:aws:logs:*:*:*"]
    },
    CXPassRole = {
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"]
    }
  }
  allowed_triggers = {
    AllowExecutionEventBridge = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.EventBridgeRule.arn
    }
  }
}

resource "aws_cloudwatch_event_rule" "EventBridgeRule" {
  name = format("serverlessrepo-Coralogix--LambdaFunctionEventBridge-${random_string.this.result}")
  event_pattern = jsonencode({
    source      = ["aws.logs"],
    detail-type = ["AWS API Call via CloudTrail"],
    detail = {
      eventSource = ["logs.amazonaws.com"],
      eventName   = ["CreateLogGroup"]
    }
  })
}

resource "aws_cloudwatch_event_target" "EventBridgeRuleTarget" {
  depends_on = [aws_cloudwatch_event_rule.EventBridgeRule]
  rule       = aws_cloudwatch_event_rule.EventBridgeRule.name
  target_id  = "LambdaFunction"
  arn        = module.lambda.lambda_function_arn
}

resource "aws_sns_topic" "this" {
  name_prefix  = "serverlessrepo-Coralogix-Lambda-Man-LambdaFunction-${random_string.this.result}-Failure"
  display_name = "serverlessrepo-Coralogix-Lambda-Man-LambdaFunction-${random_string.this.result}-Failure"
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this, module.lambda]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "aws_lambda_invocation" "trigger_lambda_for_first_time" {
  function_name = module.lambda.lambda_function_arn
  input = jsonencode({
    RequestType = "Create"
  })
}
