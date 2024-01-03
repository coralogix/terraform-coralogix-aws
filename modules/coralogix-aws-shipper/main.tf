locals {

  s3_suffix_map = {
    CloudTrail    = ".json.gz"
    VpcFlow = ".log.gz"
  }

  sns_enable = var.sns_topic_name != "" ? true : false

  log_groups = {
    for group in var.log_groups : group =>
    length(group) > 100 ? "${substr(replace(group, "/", "_"), 0, 95)}_${substr(sha256(group), 0, 4)}" : replace(group, "/", "_")
  }

  api_key_is_arn = replace(var.api_key, ":", "") != var.api_key ? true : false

    secret_access_policy = var.store_api_key_in_secrets_manager || local.api_key_is_arn ? {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = local.api_key_is_arn ? [var.api_key] : [aws_secretsmanager_secret.coralogix_secret[0].arn]
    } : {
      effect    = "Deny"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  destination_on_failure_policy = {
      effect    = "Allow"
      actions   = ["sns:publish"]
      resources = [aws_sns_topic.this.arn]
    }
}

module "locals" {
  source = "../locals_variables"

  integration_type = var.integration_type
  random_string    = random_string.this.result
}

data "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups
  name     = each.key
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_s3_bucket" "this" {
  count  = var.s3_bucket_name == null ? 0 : 1
  bucket = var.s3_bucket_name
}

data "aws_sns_topic" "sns_topic" {
  count = local.sns_enable ? 1 : 0
  name  = var.sns_topic_name
}

data "aws_iam_policy_document" "topic" {
  count = local.sns_enable && var.integration_type != "CloudWatch" && var.integration_type != "Sns" ? 1 : 0
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
    command = "curl -o coralogix-aws-shipper.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/coralogix-aws-shipper.zip ; aws s3 cp ./coralogix-aws-shipper.zip s3://coralogix-aws-shipper.zip ; rm ./coralogix-aws-shipper.zip"
  }
}

resource "aws_lambda_permission" "cloudwatch_trigger_premission" {
  for_each      = local.log_groups
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name == null ? module.locals.function_name : var.lambda_name
  principal     = "logs.amazonaws.com"
  source_arn    = "${data.aws_cloudwatch_log_group.this[each.key].arn}:*"
}

module "lambda" {
  depends_on             = [null_resource.s3_bucket_copy]
  source                 = "terraform-aws-modules/lambda/aws"
  function_name          = var.lambda_name == null ? module.locals.function_name : var.lambda_name
  description            = "Send logs to Coralogix."
  version                = "6.5.0"
  handler                = "bootstrap"
  runtime                = "provided.al2"
  architectures          = ["arm64"]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  environment_variables = {
    CORALOGIX_ENDPOINT    = var.custom_domain != "" ? "https://ingress.${var.custom_domain}" : var.subnet_ids == null ? "https://ingress.${lookup(module.locals.coralogix_domains, var.coralogix_region, "Europe")}" :  "https://ingress.private.${lookup(module.locals.coralogix_domains, var.coralogix_region, "Europe")}"
    INTEGRATION_TYPE      = var.integration_type
    RUST_LOG              = var.log_level
    CORALOGIX_API_KEY     = var.store_api_key_in_secrets_manager && !local.api_key_is_arn ? aws_secretsmanager_secret.coralogix_secret[0].arn : var.api_key
    APP_NAME         = var.application_name
    SUB_NAME         = var.subsystem_name
    NEWLINE_PATTERN  = var.newline_pattern
    BLOCKING_PATTERN = var.blocking_pattern
    SAMPLING         = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "coralogix-aws-shipper.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = var.lambda_name == null ? "${module.locals.function_name}-Role" : "${var.lambda_name}-Role"
  role_description                        = var.lambda_name == null ? "Role for ${module.locals.function_name} Lambda Function." : "Role for ${var.lambda_name} Lambda Function."
  cloudwatch_logs_retention_in_days       = var.lambda_log_retention
  create_current_version_allowed_triggers = false
  attach_policy_statements                = true
  policy_statements = var.integration_type != "CloudWatch"  && var.integration_type != "Sns" ? {
    S3 = {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${data.aws_s3_bucket.this[0].arn}/*"]
    }
    secret_permission = local.secret_access_policy
    destination_on_failure_policy = local.destination_on_failure_policy
    } : {
    secret_permission = local.secret_access_policy
    destination_on_failure_policy = local.destination_on_failure_policy
  }

  allowed_triggers = var.integration_type != "CloudWatch" && local.sns_enable != true ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this[0].arn
    }
  } : {}

  tags = merge(var.tags, module.locals.tags)
}

resource "aws_lambda_function_event_invoke_config" "invoke_on_failure" {
  depends_on = [ module.lambda ]
  count = var.notification_email != null ? 1 : 0
  function_name = var.lambda_name == null ? module.locals.function_name : var.lambda_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.this.arn
    }
  }
}

###################################
#### s3  integration resources ####
###################################

resource "aws_s3_bucket_notification" "lambda_notification" {
  count  = var.integration_type == "CloudWatch" ? 0 : local.sns_enable == false ? 1 : 0
  depends_on = [ module.lambda ]
  bucket = data.aws_s3_bucket.this[0].bucket
  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_key_prefix != null || (var.integration_type != "CloudTrail" && var.integration_type != "VpcFlow") ? var.s3_key_prefix : "AWSLogs/"
    filter_suffix       = (var.integration_type != "CloudTrail" && var.integration_type != "VpcFlow") || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(local.s3_suffix_map, var.integration_type)
  }
}

###########################################
#### cloudwatch  integration resources ####
###########################################

resource "aws_cloudwatch_log_subscription_filter" "this" {
  depends_on = [aws_lambda_permission.cloudwatch_trigger_premission]

  for_each        = local.log_groups
  name            = "${module.lambda.lambda_function_name}-Subscription-${each.key}"
  log_group_name  = data.aws_cloudwatch_log_group.this[each.key].name
  destination_arn = module.lambda.lambda_function_arn
  filter_pattern  = ""
}

resource "aws_sns_topic" "this" {
  name_prefix  = var.lambda_name == null ? "${module.locals.function_name}-Failure" : "${var.lambda_name}-Failure"
  display_name = var.lambda_name == null ? "${module.locals.function_name}-Failure" : "${var.lambda_name}-Failure"
  tags         = merge(var.tags, module.locals.tags)
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this]
  count      = var.notification_email != null ? 1 : 0
  topic_arn  = aws_sns_topic.this.arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "aws_s3_bucket_notification" "topic_notification" {
  count  = local.sns_enable == true && (var.integration_type == "S3" || var.integration_type == "CloudTrail" ) ? 1 : 0
  bucket = data.aws_s3_bucket.this[0].bucket
  topic {
    topic_arn     = data.aws_sns_topic.sns_topic[0].arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix       = var.s3_key_prefix != null || var.integration_type != "CloudTrail" ? var.s3_key_prefix : "AWSLogs/"
    filter_suffix       = var.integration_type != "CloudTrail" || var.s3_key_suffix != null ? var.s3_key_suffix : lookup(local.s3_suffix_map, var.integration_type)
  }
}

resource "aws_lambda_permission" "sns_lambda_permission" {
  count         = local.sns_enable ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name == null ? module.locals.function_name : var.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.sns_topic[count.index].arn
  depends_on    = [data.aws_sns_topic.sns_topic]
}

resource "aws_sns_topic_policy" "test" {
  count  = local.sns_enable && var.integration_type != "Sns" ? 1 : 0
  arn    = data.aws_sns_topic.sns_topic[count.index].arn
  policy = data.aws_iam_policy_document.topic[count.index].json
}

resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  count      = local.sns_enable ? 1 : 0
  depends_on = [module.lambda]
  topic_arn  = data.aws_sns_topic.sns_topic[count.index].arn
  protocol   = "lambda"
  endpoint   = module.lambda.lambda_function_arn
}

resource "aws_secretsmanager_secret" "coralogix_secret" {
  count       = var.store_api_key_in_secrets_manager && !local.api_key_is_arn? 1 : 0
  name        = var.lambda_name == null ? "lambda/coralogix/${data.aws_region.this.name}/coralogix-aws-shipper/${module.locals.function_name}" : "lambda/coralogix/${data.aws_region.this.name}/coralogix-aws-shipper/${var.lambda_name}"
  description = "Coralogix Send Your Data key Secret"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.store_api_key_in_secrets_manager && !local.api_key_is_arn? 1 : 0
  depends_on    = [aws_secretsmanager_secret.coralogix_secret]
  secret_id     = aws_secretsmanager_secret.coralogix_secret[count.index].id
  secret_string = var.api_key
}
