module "locals" {
  source = "../locals_variables"

  integration_type = "CloudWatch"
  random_string    = random_string.this.result
}

data "aws_region" "this" {}

data "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups
  name     = each.key
}

resource "random_string" "this" {
  length  = 12
  special = false
}

resource "null_resource" "s3_bucket" {
  count = var.custom_s3_bucket == "" ? 0 : 1
  provisioner "local-exec" {
    command = "curl -o cloudwatch-logs.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/cloudwatch-logs.zip ; aws s3 cp ./cloudwatch-logs.zip s3://${var.custom_s3_bucket} ; rm ./cloudwatch-logs.zip"
  }
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create                 = var.secret_manager_enabled == false ? true : false
  depends_on             = [null_resource.s3_bucket]
  function_name          = module.locals.function_name
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  attach_network_policy  = true
  environment_variables = {
    CORALOGIX_URL   = var.custom_url == "" ? "ingress.${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}" : var.custom_url
    private_key     = var.private_key
    app_name        = var.application_name
    sub_name        = var.subsystem_name
    newline_pattern = var.newline_pattern
    buffer_charset  = var.buffer_charset
    sampling        = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "cloudwatch-logs.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals.function_name}-Role"
  role_description                        = "Role for ${module.locals.function_name} Lambda Function."
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  allowed_triggers = {
    for key, value in local.log_groups : value => {
      principal  = "logs.amazonaws.com"
      source_arn = "${data.aws_cloudwatch_log_group.this[key].arn}:*"
    }
  }
  tags = merge(var.tags, module.locals.tags)
}

module "lambdaSM" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create                 = var.secret_manager_enabled ? true : false
  depends_on             = [null_resource.s3_bucket]
  layers                 = [var.layer_arn]
  function_name          = module.locals.function_name
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  attach_network_policy  = true
  environment_variables = {
    CORALOGIX_URL           = var.custom_url == "" ? "ingress.${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}" : var.custom_url
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    SECRET_NAME             = var.create_secret == "False" ? var.private_key : ""
    private_key             = "****"
    app_name                = var.application_name
    sub_name                = var.subsystem_name
    newline_pattern         = var.newline_pattern
    buffer_charset          = var.buffer_charset
    sampling                = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "cloudwatch-logs.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals.function_name}-Role"
  role_description                        = "Role for ${module.locals.function_name} Lambda Function."
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
    for key, value in local.log_groups : value => {
      principal  = "logs.amazonaws.com"
      source_arn = "${data.aws_cloudwatch_log_group.this[key].arn}:*"
    }
  }
  tags = merge(var.tags, module.locals.tags)
}

resource "aws_cloudwatch_log_subscription_filter" "this" {

  # The depends_on is required here for the allowed_triggers in the above
  # lambda module, which create aws_lambda_permission resources that are
  # prerequisite for these aws_cloudwatch_log_subscription_filter resources, to
  # finish applying before these start.
  depends_on = [module.lambda]

  for_each        = local.log_groups
  name            = "${module.lambda.lambda_function_name}-Subscription-${each.key}"
  log_group_name  = data.aws_cloudwatch_log_group.this[each.key].name
  destination_arn = var.secret_manager_enabled ? module.lambdaSM.lambda_function_arn : module.lambda.lambda_function_arn
  filter_pattern  = ""
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.lambda.lambda_function_name}-Failure"
  display_name = "${module.lambda.lambda_function_name}-Failure"
  tags         = merge(var.tags, module.locals.tags)
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this, module.lambdaSM, module.lambda]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.secret_manager_enabled && var.create_secret == "True" ? 1 : 0
  depends_on  = [module.lambdaSM]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${module.locals.function_name}"
  description = "Coralogix Send Your Data key Secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.secret_manager_enabled && var.create_secret == "True" ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
}
