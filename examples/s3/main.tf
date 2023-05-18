locals {
  function_name = "Coralogix-S3-${random_string.this.result}"
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

data "aws_region" "this" {}

data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
}

resource "random_string" "this" {
  length  = 12
  special = false
}

module "lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"

  function_name          = local.function_name
  description            = "Send logs from S3 bucket to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  environment_variables = {
    CORALOGIX_URL         = "https://${lookup(local.coralogix_regions, var.coralogix_region, "Europe")}/api/v1/logs"
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
    key    = "${var.package_name}.zip"
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
  tags = merge(var.tags, local.tags)
}

resource "aws_s3_bucket_notification" "this" {
  depends_on      = [ module.lambda ]
  bucket = data.aws_s3_bucket.this.bucket
  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_key_prefix
    filter_suffix       = var.s3_key_suffix
  }
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