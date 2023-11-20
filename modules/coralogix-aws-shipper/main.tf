module "locals" {
  source = "../locals_variables"

  integration_type = var.integration_type
  random_string    = random_string.this.result
}

locals {
  sns_enable = var.integration_type == "s3-sns" || var.integration_type == "cloudtrail-sns" ? true : false
}

data "aws_cloudwatch_log_group" "this" {
  count = var.integration_type == "cloudwatch" ? length(var.log_groups) : 0
  name  = element(var.log_groups, count.index)
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_s3_bucket" "this" {
  count = var.s3_bucket_name == null ? 0 : 1
  bucket = var.s3_bucket_name
}

data "aws_sns_topic" "sns_topic" {
  count = local.sns_enable ? 1 : 0
  name  = var.sns_topic_name
}

data "aws_iam_policy_document" "topic" {
  count = local.sns_enable && var.integration_type != "cloudwatch" ? 1 : 0
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
      values   = [data.aws_s3_bucket.this[0].arn]
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
    command = "curl -o ${var.integration_type}.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/coralogix-aws-serverless-rust.zip ; aws s3 cp ./coralogix-aws-serverless-rust.zip s3://coralogix-aws-serverless-rust.zip ; rm ./coralogix-aws-serverless-rust.zip"
  }
}

module "lambda" {
  depends_on             = [null_resource.s3_bucket_copy]
  count = var.api_key == "" ? 1:1
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = module.locals.function_name
  description            = "Send logs to Coralogix."
  handler                = "bootstrap"
  runtime                = "provided.al2"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  environment_variables = {
    CORALOGIX_ENDPOINT    = var.custom_url == "" ? "https://${lookup(module.locals.coralogix_regions, var.coralogix_region, "Europe")}${module.locals.coralogix_url_seffix}" : var.custom_url
    CORALOGIX_BUFFER_SIZE = tostring(var.buffer_size)
    INTEGRATION_TYPE      = var.integration_type
    RUST_LOG              = var.rust_log
    CORALOGIX_API_KEY     = var.store_api_key_in_secrets_manager ? aws_secretsmanager_secret_version.service_user[count.index].secret_string : var.api_key
    app_name              = var.application_name
    sub_name              = var.subsystem_name
    NEWLINE_PATTERN       = var.newline_pattern
    blocking_pattern      = var.blocking_pattern
    sampling              = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "coralogix-aws-serverless-rust.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals.function_name}-Role"
  role_description                        = "Role for ${module.locals.function_name} Lambda Function."
  cloudwatch_logs_retention_in_days       = var.cloudwatch_logs_retention_in_days
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  attach_policy_statements                = true # this is the problem that i had
  policy_statements = var.integration_type != "cloudwatch" ? {
    S3 = {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${data.aws_s3_bucket.this[0].arn}/*"]
      }
  } : {}
  # The condition will first check if the integration type is cloudwatch, in that case, it will
  # Allow the trigger from the log groups otherwise it will check if sns in enabled in
  # case that it's not then the trigger will be triggered from the bucket

  allowed_triggers = var.integration_type == "cloudwatch" ? {
    for index in range(length(var.log_groups)) : "AllowExecutionFromCloudWatch-${index}" => {
      principal  = "logs.amazonaws.com"
      source_arn = "${data.aws_cloudwatch_log_group.this[index].arn}:*"
    }
    } : local.sns_enable != true ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this[0].arn
    }
  } : {}

  tags = merge(var.tags, module.locals.tags)
}

###################################
#### s3  integration resources ####
###################################

resource "aws_s3_bucket_notification" "lambda_notification" {
  count  = var.integration_type == "cloudwatch" ? 0 : local.sns_enable == false ? 1 : 0
  bucket = data.aws_s3_bucket.this[0].bucket
  lambda_function {
    lambda_function_arn =  module.lambda[count.index].lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.integration_type == "s3" || var.s3_key_prefix != null ? var.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/${lookup(module.locals.s3_prefix_map, var.integration_type)}/"
    filter_suffix       = var.integration_type == "s3" || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(module.locals.s3_suffix_map, var.integration_type)
  }
}

resource "aws_s3_bucket_notification" "topic_notification" {
  count  = var.integration_type == "cloudwatch" ? 0 : local.sns_enable == true ? 1 : 0
  bucket = data.aws_s3_bucket.this[0].bucket
  topic {
    topic_arn     = data.aws_sns_topic.sns_topic[count.index].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.integration_type == "s3-sns" || var.s3_key_prefix != null ? var.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/Cloudtrail/"
    filter_suffix = var.integration_type == "s3-sns" || var.s3_key_suffix != null ? var.s3_key_suffix : ".json.gz"
  }
}

###########################################
#### cloudwatch  integration resources ####
###########################################

resource "aws_cloudwatch_log_subscription_filter" "this" {
  # The depends_on is required here for the allowed_triggers in the above
  # lambda module, which creates aws_lambda_permission resources that are
  # prerequisite for these aws_cloudwatch_log_subscription_filter resources, to
  # finish applying before these start.
  depends_on = [module.lambda]

  count           = var.integration_type == "cloudwatch" ? length(var.log_groups) : 0
  name            = "${module.lambda[count.index].lambda_function_name}-Subscription-${count.index}"
  log_group_name  = data.aws_cloudwatch_log_group.this[count.index].name
  destination_arn = module.lambda[count.index].lambda_function_arn
  filter_pattern  = ""
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${module.locals.function_name}-Failure"
  display_name = "${module.locals.function_name}-Failure"
  tags         = merge(var.tags, module.locals.tags)
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
  depends_on = [module.lambda]
  topic_arn  = data.aws_sns_topic.sns_topic[count.index].arn
  protocol   = "lambda"
  endpoint   = module.lambda[count.index].lambda_function_arn
}

resource "aws_secretsmanager_secret" "coralogix_secret" {
  count              = var.store_api_key_in_secrets_manager ? 1 : 0
  # depends_on  = [module.lambda]
  name        = "CoralogixApiKey"
  description = "Coralogix Send Your Data key Secret"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count              = var.store_api_key_in_secrets_manager ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.coralogix_secret]
  secret_id     = aws_secretsmanager_secret.coralogix_secret[count.index].id
  secret_string = var.api_key
}
