locals {
  function_name = "Coralogix-CloudWatch-${random_string.this.result}"
  coralogix_regions = {
    Europe    = "api.coralogix.com"
    Europe2   = "api.eu2.coralogix.com"
    India     = "api.app.coralogix.in"
    Singapore = "api.coralogixsg.com"
    US        = "api.coralogix.us"
  }
  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }
}

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
  version                = "3.2.1"

  function_name          = local.function_name
  description            = "Send CloudWatch logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs12.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  local_existing_package = "${path.module}/dist/package.zip"
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    CORALOGIX_URL   = lookup(local.coralogix_regions, var.coralogix_region, "Europe")
    private_key     = var.private_key
    app_name        = var.application_name
    sub_name        = var.subsystem_name
    newline_pattern = var.newline_pattern
    buffer_charset  = var.buffer_charset
    sampling        = tostring(var.sampling_rate)
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

resource "aws_cloudwatch_log_subscription_filter" "this" {

  # The depends_on is required here for the allowed_triggers in the above
  # lambda module, which create aws_lambda_permission resources that are
  # prerequisite for these aws_cloudwatch_log_subscription_filter resources, to
  # finish applying before these start.
  depends_on      = [ module.lambda ]

  count           = length(var.log_groups)
  name            = "${module.lambda.lambda_function_name}-Subscription-${count.index}"
  log_group_name  = data.aws_cloudwatch_log_group.this[count.index].name
  destination_arn = module.lambda.lambda_function_arn
  filter_pattern  = ""
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.lambda.lambda_function_name}-Failure"
  display_name = "${module.lambda.lambda_function_name}-Failure"
  tags         = merge(var.tags, local.tags)
}

resource "aws_sns_topic_subscription" "this" {
  count     = var.notification_email != null ? 1 : 0
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.notification_email
}
