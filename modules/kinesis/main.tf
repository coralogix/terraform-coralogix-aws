module "locals" {
  source = "../locals_variables"

  integration_type = "kinesis"
  random_string    = random_string.this.result
}

data "aws_region" "this" {}

data "aws_kinesis_stream" "stream" {
  name = var.kinesis_stream_name
}

resource "random_string" "this" {
  length  = 6
  special = false
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.3.1"
  create                 = var.ssm_enable != "True" ? true : false
  layers                 = [var.layer_arn]
  function_name          = module.locals.function_name
  description            = "Send kinesis data stream logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    coralogix_url   = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
    private_key     = var.private_key
    app_name        = var.application_name
    sub_name        = var.subsystem_name
    newline_pattern = var.newline_pattern
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "${var.package_name}.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals.function_name}-Role"
  role_description                        = "Role for ${module.locals.function_name} Lambda Function."
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  event_source_mapping = {
    kinesis = {
      event_source_arn  = data.aws_kinesis_stream.stream.arn
      starting_position = "LATEST"
    }
  }
  allowed_triggers = {
    kinesis = {
      principal  = "kinesis.amazonaws.com"
      source_arn = data.aws_kinesis_stream.stream.arn
    }
  }
  attach_policies    = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole",
  ]
  tags = merge(var.tags, module.locals.tags)
}

module "lambda_ssm" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.3.1"
  create  = var.ssm_enable == "True" ? true : false

  layers                 = [var.layer_arn]
  function_name          = module.locals.function_name
  description            = "Send kinesis data stream logs to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    coralogix_url           = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    private_key             = "****"
    app_name                = var.application_name
    sub_name                = var.subsystem_name
    newline_pattern         = var.newline_pattern
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "${var.package_name}.zip"
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
  event_source_mapping = {
    kinesis = {
      event_source_arn  = data.aws_kinesis_stream.stream.arn
      starting_position = "LATEST"
    }
  }
  allowed_triggers = {
    kinesis = {
      principal  = "kinesis.amazonaws.com"
      source_arn = data.aws_kinesis_stream.stream.arn
    }
  }
  attach_policies    = true
  number_of_policies = 1
  policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole",
  ]
  tags = merge(var.tags, module.locals.tags)
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.lambda.lambda_function_name}-Failure"
  display_name = "${module.lambda.lambda_function_name}-Failure"
  tags         = merge(var.tags, module.locals.tags)
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this, module.lambda_ssm, module.lambda]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.ssm_enable == "True" ? 1 : 0
  depends_on  = [module.lambda_ssm]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${module.locals.function_name}"
  description = "Coralogix Send Your Data key Secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.ssm_enable == "True" ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
}
