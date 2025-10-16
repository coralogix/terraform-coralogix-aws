locals {
  function_name = "Coralogix-${var.package_name}-${random_string.this.result}"
  coralogix_regions = {
    Europe    = "ingress.eu1.coralogix.com:443"
    Europe2   = "ingress.eu2.coralogix.com:443"
    India     = "ingress.ap1.coralogix.com:443"
    Singapore = "ingress.ap2.coralogix.com:443"
    US        = "ingress.us1.coralogix.com:443"
    US2       = "ingress.us2.coralogix.com:443"
    Custom    = var.custom_url
  }
  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }

  # Base environment variables (common to both scenarios)
  base_environment_variables = {
    CORALOGIX_METADATA_URL               = lookup(local.coralogix_regions, var.coralogix_region, "Europe")
    LATEST_VERSIONS_PER_FUNCTION         = var.latest_versions_per_function
    COLLECT_ALIASES                      = var.collect_aliases == true ? "True" : "False"
    LAMBDA_FUNCTION_INCLUDE_REGEX_FILTER = var.lambda_function_include_regex_filter
    LAMBDA_FUNCTION_EXCLUDE_REGEX_FILTER = var.lambda_function_exclude_regex_filter
    LAMBDA_FUNCTION_TAG_FILTERS          = var.lambda_function_tag_filters
    RESOURCE_TTL_MINUTES                 = var.resource_ttl_minutes
    AWS_RETRY_MODE                       = "adaptive"
    AWS_MAX_ATTEMPTS                     = 10
  }

  # Secret manager specific environment variables
  secret_manager_environment_variables = var.secret_manager_enabled ? {
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    SECRET_NAME             = var.create_secret == false ? var.private_key : ""
  } : {}

  # Basic scenario environment variables
  basic_environment_variables = var.secret_manager_enabled ? {} : {
    private_key = var.private_key
  }

  # Combined environment variables
  environment_variables = merge(
    local.base_environment_variables,
    local.secret_manager_environment_variables,
    local.basic_environment_variables
  )
}

data "aws_region" "this" {}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.17.1"

  create_bus  = false
  create_role = false
  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = var.schedule
    }
  }

  targets = {
    crons = [
      {
        name  = "cron-for-lambda"
        arn   = module.lambda.lambda_function_arn
        input = jsonencode({ "job" : "cron-by-rate" })
      }
    ]
  }
}

resource "random_string" "this" {
  length  = 12
  special = false
}

resource "null_resource" "s3_bucket" {
  count = var.custom_s3_bucket == "" ? 0 : 1
  provisioner "local-exec" {
    command = "curl -o ${var.package_name}.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/${var.package_name}.zip ; aws s3 cp ./${var.package_name}.zip s3://${var.custom_s3_bucket} ; rm ./${var.package_name}.zip"
  }
}

module "lambda" {
  depends_on             = [null_resource.s3_bucket]
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = local.function_name
  layers                 = var.secret_manager_enabled ? [var.layer_arn] : []
  description            = "Send metadata to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs20.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables  = local.environment_variables
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.id}" : var.custom_s3_bucket
    key    = "${var.package_name}.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${local.function_name}-Role"
  role_description                        = "Role for ${local.function_name} Lambda Function."
  cloudwatch_logs_retention_in_days       = var.cloudwatch_logs_retention_in_days
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  attach_policy_statements                = true
  policy_statements = {
    allow = {
      sid    = "GetLambdaMetadata"
      effect = "Allow"
      actions = [
        "ec2:DescribeInstances",
        "lambda:ListFunctions",
        "lambda:ListVersionsByFunction",
        "lambda:GetFunction",
        "lambda:ListAliases",
        "lambda:ListEventSourceMappings",
        "lambda:GetPolicy"
      ]
      resources = ["*"]
    }
  }
  allowed_triggers = {
    ScanAmiRule = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["crons"]
    }
  }

  tags = merge(var.tags, local.tags)
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${local.function_name}-Failure"
  display_name = "${local.function_name}-Failure"
  tags         = merge(var.tags, local.tags)
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.secret_manager_enabled && var.create_secret ? 1 : 0
  depends_on  = [module.lambda]
  name        = "lambda/coralogix/${data.aws_region.this.id}/${local.function_name}"
  description = "Coralogix Send Your Data key Secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.secret_manager_enabled && var.create_secret ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
}

# Separate IAM policy for secret access - created after both Lambda and secret exist
resource "aws_iam_policy" "secret_access_policy" {
  count = var.secret_manager_enabled ? 1 : 0

  name        = "${local.function_name}-SecretAccess"
  path        = "/coralogix/"
  description = "Policy for Lambda to access Coralogix secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret"
        ]
        Resource = var.create_secret ? [aws_secretsmanager_secret.private_key_secret[0].arn] : [
          startswith(var.private_key, "arn:${data.aws_partition.current.partition}:secretsmanager:") ? var.private_key : "arn:${data.aws_partition.current.partition}:secretsmanager:${data.aws_region.this.id}:${data.aws_caller_identity.current.account_id}:secret:${var.private_key}*"
        ]
      }
    ]
  })

  tags = merge(var.tags, local.tags)
}

resource "aws_iam_role_policy_attachment" "secret_access_policy_attachment" {
  count = var.secret_manager_enabled ? 1 : 0

  role       = module.lambda.lambda_role_name
  policy_arn = aws_iam_policy.secret_access_policy[0].arn
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}
