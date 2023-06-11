data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
}

module "locals" {
  source = "../locals_variables"

  integration_type = var.integration_type
  random_string    = random_string.this.result
}

resource "random_string" "this" {
  length  = 12
  special = false
}

module "lambda" {
  create                 = var.ssm_enable != "True" ? true : false
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = module.locals.function_name
  description            = "Send logs from S3 bucket to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    coralogix_url         = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
    CORALOGIX_BUFFER_SIZE = tostring(var.buffer_size)
    private_key           = var.private_key
    app_name              = var.application_name
    sub_name              = var.subsystem_name
    newline_pattern       = var.newline_pattern
    blocking_pattern      = var.blocking_pattern
    sampling              = tostring(var.sampling_rate)
    debug                 = tostring(var.debug)
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "${var.integration_type}.zip"
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
    S3 = {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${data.aws_s3_bucket.this.arn}/*"]
    }
  }
  allowed_triggers = {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this.arn
    }
  }

  tags = merge(var.tags, module.locals.tags)
}

module "lambdaSSM" {
  source                 = "terraform-aws-modules/lambda/aws"
  create                 = var.ssm_enable == "True" ? true : false
  version                = "3.2.1"
  layers                 = [var.layer_arn]
  function_name          = module.locals.function_name
  description            = "Send logs from S3 bucket to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    coralogix_url           = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
    CORALOGIX_BUFFER_SIZE   = tostring(var.buffer_size)
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    app_name                = var.application_name
    sub_name                = var.subsystem_name
    newline_pattern         = var.newline_pattern
    blocking_pattern        = var.blocking_pattern
    sampling                = tostring(var.sampling_rate)
    debug                   = tostring(var.debug)
  }
  s3_existing_package = {
    bucket = "coralogix-serverless-repo-${data.aws_region.this.name}"
    key    = "${var.integration_type}.zip"
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
    S3 = {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${data.aws_s3_bucket.this.arn}/*"]
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
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this.arn
    }
  }
  tags = merge(var.tags, module.locals.tags)
}

resource "aws_s3_bucket_notification" "this" {
  bucket = data.aws_s3_bucket.this.bucket
  lambda_function {
    lambda_function_arn = var.ssm_enable == "True" ? module.lambdaSSM.lambda_function_arn : module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.integration_type == "s3" || var.s3_key_prefix != null ? var.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/${lookup(module.locals.s3_prefix_map, var.integration_type)}/"
    filter_suffix       = var.integration_type == "s3" || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(module.locals.s3_suffix_map, var.integration_type)
  }
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.locals.function_name}-Failure"
  display_name = "${module.locals.function_name}-Failure"
  tags         = merge(var.tags, module.locals.tags)
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.ssm_enable == "True" ? 1 : 0
  depends_on  = [module.lambdaSSM]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${module.locals.function_name}"
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


