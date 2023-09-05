module "locals" {
  source = "../locals_variables"

  integration_type = var.integration_type
  random_string    = random_string.this.result

}

locals {
  sns_enable = var.integration_type == "s3-sns" || var.integration_type == "cloudtrail-sns" ? true : false
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_s3_bucket" "this" {
  bucket = var.s3_bucket_name
}

data "aws_sns_topic" "sns_topic" {
  count = local.sns_enable ? 1 : 0
  name  = var.sns_topic_name
}

data "aws_iam_policy_document" "topic" {
  count = local.sns_enable ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:${data.aws_sns_topic.sns_topic[count.index].name}"]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [data.aws_s3_bucket.this.arn]
    }
  }
}

resource "random_string" "this" {
  length  = 6
  special = false
}

resource "null_resource" "s3_bucket_copy" {
  count = var.custom_s3_bucket == "" ? 0 : 1
  provisioner "local-exec" {
    command = "curl -o ${var.integration_type}.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/${var.integration_type}.zip ; aws s3 cp ./${var.integration_type}.zip s3://${var.custom_s3_bucket} ; rm ./${var.integration_type}.zip"
  }
}

module "lambda" {
  create                 = var.layer_arn == "" ? true : false
  depends_on             = [ null_resource.s3_bucket_copy ]
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
    CORALOGIX_URL         = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
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
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
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
  allowed_triggers = local.sns_enable != true ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this.arn
    }
  } : {}

  tags = merge(var.tags, module.locals.tags)
}

module "lambdaSSM" {
  source                 = "terraform-aws-modules/lambda/aws"
  create                 = var.layer_arn != "" ? true : false
  depends_on             = [ null_resource.s3_bucket_copy ]
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
    CORALOGIX_URL           = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
    CORALOGIX_BUFFER_SIZE   = tostring(var.buffer_size)
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    SECRET_NAME             = var.create_secret == "False" ? var.private_key : ""
    app_name                = var.application_name
    sub_name                = var.subsystem_name
    newline_pattern         = var.newline_pattern
    blocking_pattern        = var.blocking_pattern
    sampling                = tostring(var.sampling_rate)
    debug                   = tostring(var.debug)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
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
  allowed_triggers = local.sns_enable != true ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this.arn
    }
  } : {}
  tags = merge(var.tags, module.locals.tags)
}

resource "aws_s3_bucket_notification" "lambda_notification" {
  count  = local.sns_enable == false ? 1 : 0
  bucket = data.aws_s3_bucket.this.bucket
  lambda_function {
    lambda_function_arn = var.layer_arn != "" ? module.lambdaSSM.lambda_function_arn : module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.integration_type == "s3" || var.s3_key_prefix != null ? var.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/${lookup(module.locals.s3_prefix_map, var.integration_type)}/"
    filter_suffix       = var.integration_type == "s3" || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(module.locals.s3_suffix_map, var.integration_type)
  }
}

resource "aws_s3_bucket_notification" "topic_notification" {
  count  = local.sns_enable == true ? 1 : 0
  bucket = data.aws_s3_bucket.this.bucket
  topic {
    topic_arn     = data.aws_sns_topic.sns_topic[count.index].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.integration_type == "s3-sns" || var.s3_key_prefix != null ? var.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/Cloudtrail/"
    filter_suffix = var.integration_type == "s3-sns" || var.s3_key_suffix != null ? var.s3_key_suffix : ".json.gz"
  }
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.locals.function_name}-Failure"
  display_name = "${module.locals.function_name}-Failure"
  tags         = merge(var.tags, module.locals.tags)
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.layer_arn != "" && var.create_secret == "True"  ? 1 : 0
  depends_on  = [module.lambdaSSM]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${module.locals.function_name}"
  description = "Coralogix Send Your Data key Secret"
}
resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.layer_arn != "" && var.create_secret == "True"  ? 1 : 0
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

resource "aws_lambda_permission" "sns_lambda_permission" {
  count         = local.sns_enable ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.locals.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.sns_topic[count.index].arn
  depends_on    = [data.aws_sns_topic.sns_topic]
}

resource "aws_sns_topic_policy" "test" {
  count  = local.sns_enable ? 1 : 0
  arn    = data.aws_sns_topic.sns_topic[count.index].arn
  policy = data.aws_iam_policy_document.topic[count.index].json
}

resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  count      = local.sns_enable ? 1 : 0
  depends_on = [module.lambdaSSM, module.lambda]
  topic_arn  = data.aws_sns_topic.sns_topic[count.index].arn
  protocol   = "lambda"
  endpoint   = var.layer_arn != "" ? module.lambdaSSM.lambda_function_arn : module.lambda.lambda_function_arn
}
