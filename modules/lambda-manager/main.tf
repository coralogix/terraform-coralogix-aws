data "aws_region" "this" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  log_groups_prefix_string = join(",", var.log_group_permissions_prefix)
  is_firehose              = lower(var.destination_type) == "firehose"
  sns_kms_key_resource = coalesce(
    var.sns_kms_key_arn,
    "arn:${data.aws_partition.current.partition}:kms:${data.aws_region.this.id}:${data.aws_caller_identity.current.account_id}:key/00000000-0000-0000-0000-000000000000"
  )
  destination_policy_statement = local.is_firehose ? {
    CXPassRole = {
      effect    = "Allow"
      actions   = ["iam:PassRole"]
      resources = ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/*"]
    }
    } : {
    CXAddDestinationPermission = {
      effect    = "Allow"
      actions   = ["lambda:AddPermission"]
      resources = [var.destination_arn]
    }
  }
  package_key = "lambda-manager-${var.lambda_manager_version}.zip"
  policy_statements = merge({
    CWSubscriptionPolicy = {
      effect = "Allow"
      actions = [
        "logs:PutSubscriptionFilter",
        "logs:DeleteSubscriptionFilter",
        "logs:DescribeSubscriptionFilters"
      ]
      resources = ["arn:${data.aws_partition.current.partition}:logs:*:*:*"]
    },
    CWDescribeLogGroups = {
      # ponytail: a list call has no log group to scope to, so it gets "*"
      effect    = "Allow"
      actions   = ["logs:DescribeLogGroups"]
      resources = ["*"]
    },
    CWLogGroupTagPolicy = {
      effect    = "Allow"
      actions   = ["logs:TagResource", "logs:UntagResource"]
      resources = ["arn:${data.aws_partition.current.partition}:logs:${data.aws_region.this.id}:${data.aws_caller_identity.current.account_id}:log-group:*"]
    },
    GetManagedLogGroupsByTag = {
      effect    = "Allow"
      actions   = ["tag:GetResources"]
      resources = ["*"]
    },
    SnsKms = {
      effect    = "Allow"
      actions   = ["kms:Decrypt", "kms:GenerateDataKey*"]
      resources = [local.sns_kms_key_resource]
    }
  }, local.destination_policy_statement)
}

resource "random_string" "this" {
  length  = 12
  special = false
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "8.1.2"
  function_name          = "serverlessrepo-Coralogix-Lambda-Man-LambdaFunction-${random_string.this.result}"
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "lambda_function.lambda_handler"
  runtime                = "python3.14"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  # Lambda Manager 3.0.0 runs one reconcile at a time.
  reserved_concurrent_executions = 1
  environment_variables = {
    LOGS_FILTER                       = var.logs_filter
    REGEX_PATTERN                     = var.regex_pattern
    DESTINATION_ARN                   = var.destination_arn
    DESTINATION_ROLE                  = var.destination_role
    ADOPT_LEGACY_FILTERS              = var.adopt_legacy_filters
    AWS_API_REQUESTS_LIMIT            = var.aws_api_requests_limit
    LOG_GROUP_PERMISSION_PREFIX       = local.log_groups_prefix_string
    DISABLE_ADD_PERMISSION            = var.disable_add_permission
    ADD_PERMISSIONS_TO_ALL_LOG_GROUPS = var.add_permissions_to_all_log_groups
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.id}"
    key    = local.package_key
  }
  role_path                               = "/coralogix/"
  role_name                               = "serverlessrepo-Coralogix-Lambda-Man-${random_string.this.result}-Role"
  role_description                        = "Role for serverlessrepo-Coralogix-Lambda-Man-${random_string.this.result} Lambda Function."
  create_current_version_allowed_triggers = false
  attach_policy_statements                = true
  policy_statements                       = local.policy_statements
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
      eventName   = ["CreateLogGroup"],
      requestParameters = {
        logGroupClass = [
          { exists = false },
          "STANDARD"
        ]
      }
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
  name_prefix       = "serverlessrepo-Coralogix-Lambda-Man-LambdaFunction-${random_string.this.result}-Failure"
  display_name      = "serverlessrepo-Coralogix-Lambda-Man-LambdaFunction-${random_string.this.result}-Failure"
  kms_master_key_id = var.sns_kms_key_arn
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this, module.lambda]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "time_sleep" "iam_propagation" {
  # ponytail: flat 10s wait beats a retry wrapper, raise it if a first apply still races
  count           = var.enable_reconcile ? 1 : 0
  depends_on      = [module.lambda]
  create_duration = "10s"
}

resource "aws_lambda_invocation" "trigger_lambda_for_first_time" {
  count           = var.enable_reconcile ? 1 : 0
  depends_on      = [time_sleep.iam_propagation]
  function_name   = module.lambda.lambda_function_arn
  lifecycle_scope = "CRUD"
  input = jsonencode({
    RequestType = "Reconcile"
  })
  triggers = {
    config = sha256(jsonencode({
      regex_pattern                     = var.regex_pattern
      logs_filter                       = var.logs_filter
      destination_arn                   = var.destination_arn
      destination_role                  = var.destination_role
      disable_add_permission            = var.disable_add_permission
      add_permissions_to_all_log_groups = var.add_permissions_to_all_log_groups
      log_group_permissions_prefix      = local.log_groups_prefix_string
      adopt_legacy_filters              = var.adopt_legacy_filters
      lambda_manager_version            = var.lambda_manager_version
    }))
  }
}
