locals {
  function_name = "Coralogix-${var.package_name}-${random_string.this.result}"
  coralogix_regions = {
    Europe    = "ingress.coralogix.com:443"
    Europe2   = "ingress.eu2.coralogix.com:443"
    India     = "ingress.app.coralogix.in:443"
    Singapore = "ingress.coralogixsg.com:443"
    US        = "ingress.coralogix.us:443"
    US2       = "ingress.cx498.coralogix.com:443"
    Custom    = var.custom_url
  }
  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }
}

data "aws_region" "this" {}

module "eventbridge" {
  source = "terraform-aws-modules/eventbridge/aws"

  create_bus = false

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
        arn   = var.ssm_enable != "True" ? module.lambda.lambda_function_arn : module.lambdaSSM.lambda_function_arn
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
  create                 = var.ssm_enable != "True" ? true : false
  depends_on             = [ null_resource.s3_bucket ]
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = local.function_name
  description            = "Send metadata to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs18.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    CORALOGIX_METADATA_URL       = lookup(local.coralogix_regions, var.coralogix_region, "Europe")
    private_key                  = var.private_key
    LATEST_VERSIONS_PER_FUNCTION = var.latest_versions_per_function
    COLLECT_ALIASES              = var.collect_aliases
    RESOURCE_TTL_MINUTES         = var.resource_ttl_minutes
    AWS_RETRY_MODE               = "adaptive"
    AWS_MAX_ATTEMPTS             = 10
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "${var.package_name}.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${local.function_name}-Role"
  role_description                        = "Role for ${local.function_name} Lambda Function."
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

module "lambdaSSM" {
  create                 = var.ssm_enable == "True" ? true : false
  depends_on             = [ null_resource.s3_bucket ]
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = local.function_name
  layers                 = [var.layer_arn]
  description            = "Send metadata to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs18.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    CORALOGIX_METADATA_URL       = lookup(local.coralogix_regions, var.coralogix_region, "Europe")
    AWS_LAMBDA_EXEC_WRAPPER      =  "/opt/wrapper.sh"
    LATEST_VERSIONS_PER_FUNCTION = var.latest_versions_per_function
    RESOURCE_TTL_MINUTES         = var.resource_ttl_minutes
    COLLECT_ALIASES              = var.collect_aliases
    AWS_RETRY_MODE               = "adaptive"
    AWS_MAX_ATTEMPTS             = 10
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "${var.package_name}.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${local.function_name}-Role"
  role_description                        = "Role for ${local.function_name} Lambda Function."
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
    secret_access_policy = {
      effect = "Allow"
      actions = [
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue",
        "secretsmanager:UpdateSecret"
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
  count       = var.ssm_enable == "True" ? 1 : 0
  depends_on  = [module.lambdaSSM]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${local.function_name}"
  description = "Coralogix Send Your Data key Secret"
}
resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.ssm_enable == "True" ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}