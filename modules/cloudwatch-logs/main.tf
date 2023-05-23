locals {
  function_name = "Coralogix-CloudWatch-${random_string.this.result}"
  coralogix_regions = {
    Europe    = "ingress.coralogix.com"
    Europe2   = "ingress.eu2.coralogix.com"
    India     = "ingress.coralogix.in"
    Singapore = "ingress.coralogixsg.com"
    US        = "ingress.coralogix.us"
    Custom    = var.custom_domain
  }
  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }
}

data "aws_region" "this" {}

data "aws_cloudwatch_log_group" "this" {
  count    = length(var.log_groups)
  name     = element(var.log_groups, count.index)
}

resource "random_string" "this" {
  length  = 12
  special = false
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create = var.ssm_enable != "True" ? true : false

  function_name          = local.function_name
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    CORALOGIX_URL   = var.custom_domain == "" ? lookup(local.coralogix_regions, var.coralogix_region, "Europe") : var.custom_domain
    private_key     = var.private_key
    app_name        = var.application_name
    sub_name        = var.subsystem_name
    newline_pattern = var.newline_pattern
    buffer_charset  = var.buffer_charset
    sampling        = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "cloudwatch-logs.zip"
  }
  policy_path            = "/coralogix/"
  role_path              = "/coralogix/"
  role_name              = "${local.function_name}-Role"
  role_description       = "Role for ${local.function_name} Lambda Function."
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  allowed_triggers = {
    for index in range(length(var.log_groups)) : "AllowExecutionFromCloudWatch-${index}" => {
      principal  = "logs.amazonaws.com"
      source_arn = "${data.aws_cloudwatch_log_group.this[index].arn}:*"
    }
  }
  tags = merge(var.tags, local.tags)
}

module "lambdaSSM" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create = var.ssm_enable == "True" ? true : false 

  layers                 = [var.layer_arn] 
  function_name          = local.function_name
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    CORALOGIX_URL   = var.custom_domain == "" ? lookup(local.coralogix_regions, var.coralogix_region, "Europe") : var.custom_domain
    AWS_LAMBDA_EXEC_WRAPPER: "/opt/wrapper.sh" 
    private_key     = "****" 
    app_name        = var.application_name
    sub_name        = var.subsystem_name
    newline_pattern = var.newline_pattern
    buffer_charset  = var.buffer_charset
    sampling        = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "cloudwatch-logs.zip"
  }
  policy_path            = "/coralogix/"
  role_path              = "/coralogix/"
  role_name              = "${local.function_name}-Role"
  role_description       = "Role for ${local.function_name} Lambda Function."
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  attach_policy_statements                = true 
  policy_statements = { 
    access_secret_policy = { 
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
    for index in range(length(var.log_groups)) : "AllowExecutionFromCloudWatch-${index}" => {
      principal  = "logs.amazonaws.com"
      source_arn = "${data.aws_cloudwatch_log_group.this[index].arn}:*"
    }
  }
  tags = merge(var.tags, local.tags)
}

resource "aws_cloudwatch_log_subscription_filter" "this" {

  # The depends_on is required here for the allowed_triggers in the above
  # lambda module, which create aws_lambda_permission resources that are
  # prerequisite for these aws_cloudwatch_log_subscription_filter resources, to
  # finish applying before these start.
  depends_on      = [ module.lambda ]

  count           = length(var.log_groups)
  name            = "${module.lambda.lambda_function_name}-Subscription-${count.index}"
  log_group_name  = data.aws_cloudwatch_log_group.this[count.index].name
  destination_arn = var.ssm_enable == "True" ?  module.lambdaSSM.lambda_function_arn : module.lambda.lambda_function_arn 
  filter_pattern  = ""
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.lambda.lambda_function_name}-Failure"
  display_name = "${module.lambda.lambda_function_name}-Failure"
  tags         = merge(var.tags, local.tags)
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this,module.lambdaSSM,module.lambda] 
  count     = var.notification_email != null ? 1 : 0
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count = var.ssm_enable == "True" ? 1 : 0
  depends_on = [ module.lambdaSSM ]
  name         = "lambda/coralogix/${data.aws_region.this.name}/${local.function_name}"
  description  = "Coralogix Send Your Data key Secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count = var.ssm_enable == "True" ? 1 : 0
  depends_on = [ aws_secretsmanager_secret.private_key_secret ]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
}

