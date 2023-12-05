locals {
  sns_enable = var.sns_topic_name != "" ? true : false
  default_newline          = "(?:\\r\\n|\\r|\\n)"
  default_blocking_pattern = ""
	# private_link_enable      = var.security_group_ids != "" ? true : false    
  log_groups = {
    for group in var.log_groups : group =>
    length(group) > 100 ? "${substr(replace(group, "/", "_"), 0, 95)}_${substr(sha256(group), 0, 4)}" : replace(group, "/", "_")
  }
}

module "locals" {
  for_each = var.log_info
  source   = "../locals_variables"

  integration_type = each.value.integration_type
  random_string    = "${each.key}-${random_string.this.result}"
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups
  name     = each.key
}

data "aws_s3_bucket" "this" {
  count = var.s3_bucket_name != "" ? 1 : 0
  bucket = var.s3_bucket_name
}

data "aws_sns_topic" "sns_topic" {
  count = var.sns_topic_name != null ? 1 : 0
  name  = var.sns_topic_name
}

data "aws_iam_policy_document" "topic" {
  count = var.sns_topic_name != null ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["SNS:Publish"]
    resources = [
      "arn:aws:sns:*:*:${data.aws_sns_topic.sns_topic[count.index].name}"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [var.s3_bucket_name]
    }
  }
}


resource "random_string" "this" {
  length  = 6
  special = false
}

resource "null_resource" "s3_bucket_copy" {
  for_each = var.custom_s3_bucket == "" ? {} : var.log_info
  provisioner "local-exec" {
    command = "curl -o ${each.value.integration_type}.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/${each.value.integration_type}.zip ; aws s3 cp ./${each.value.integration_type}.zip s3://${var.custom_s3_bucket} ; rm ./${each.value.integration_type}.zip"
  }
}

module "lambda" {
  for_each               = var.log_info
  depends_on             = [null_resource.s3_bucket_copy]
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = module.locals[each.key].function_name
  description            = "Send logs from S3 bucket to Coralogix."
  handler                = "bootstrap"
  runtime                = "provided.al2"
  architectures          = ["arm64"]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this[each.key].arn
  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = var.security_group_ids
  environment_variables = {
    CORALOGIX_ENDPOINT    = var.custom_url != "" ? var.custom_url : "https://${lookup(module.locals[each.key].coralogix_regions, var.coralogix_region, "Europe")}"
    INTEGRATION_TYPE      = each.value.integration_type
    CORALOGIX_BUFFER_SIZE = tostring(var.buffer_size)
    RUST_LOG              = var.rust_log
    CORALOGIX_API_KEY     = var.api_key
    APP_NAME              = each.value.application_name
    SUB_NAME              = each.value.subsystem_name
    NEWLINE_PATTERN       = each.value.newline_pattern == null ? local.default_newline : each.value.newline_pattern
    BLOCKING_PATTERN      = each.value.blocking_pattern == null ? local.default_newline : each.value.blocking_pattern
    SAMPLING              = tostring(var.sampling_rate)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "coralogix-aws-shipper.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals[each.key].function_name}-Role"
  role_description                        = "Role for ${module.locals[each.key].function_name} Lambda Function."
  cloudwatch_logs_retention_in_days       = var.cloudwatch_logs_retention_in_days
  create_current_version_allowed_triggers = false
  create_async_event_config               = true
  attach_async_event_policy               = true
  attach_policy_statements                = each.value.integration_type == "cloudwatch" ? false : true
  policy_statements = each.value.integration_type != "cloudwatch" ? {
    S3 = {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${data.aws_s3_bucket.this[0].arn}/*"]
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
    } : {
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
  allowed_triggers = each.value.integration_type == "cloudwatch" ? {
    for key, value in local.log_groups : value => {
      principal  = "logs.amazonaws.com"
      source_arn = "${data.aws_cloudwatch_log_group.this[key].arn}:*"
    }
    } : local.sns_enable != true ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this[0].arn
    }
  } : {}

  tags = merge(var.tags, module.locals[each.key].tags)
}

resource "aws_s3_bucket_notification" "lambda_notification" {
  count  = var.sns_topic_name == null ? 1 : 0
  bucket = data.aws_s3_bucket.this[0].bucket
  dynamic "lambda_function" {
    for_each = var.log_info
    iterator = log_info
    content {
      lambda_function_arn =  module.lambda[log_info.key].lambda_function_arn
      events              = ["s3:ObjectCreated:*"]
      filter_prefix       = log_info.value.integration_type == "s3" || log_info.value.s3_key_prefix != null ? log_info.value.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/${lookup(module.locals[log_info.key].s3_prefix_map, log_info.value.integration_type)}/"
      filter_suffix       = log_info.value.integration_type == "s3" || log_info.value.s3_key_suffix != null ? log_info.value.s3_key_suffix : lookup(module.locals[log_info.key].s3_suffix_map, log_info.value.integration_type)
    }
  }
}

resource "aws_s3_bucket_notification" "topic_notification" {
  count  = var.sns_topic_name != null ? 1 : 0
  bucket = data.aws_s3_bucket.this.bucket
  dynamic "topic" {
    for_each = var.log_info
    iterator = log_info

    content {
      topic_arn     = data.aws_sns_topic.sns_topic[count.index].arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = log_info.value.integration_type == "s3-sns" || log_info.value.s3_key_prefix != null ? log_info.value.s3_key_prefix : "AWSLogs/${data.aws_caller_identity.this.account_id}/Cloudtrail/"
      filter_suffix = log_info.value.integration_type == "s3-sns" || log_info.value.s3_key_suffix != null ? log_info.value.s3_key_suffix : ".json.gz"
    }
  }
}

###########################################
#### cloudwatch  integration resources ####
###########################################

resource "aws_cloudwatch_log_subscription_filter" "this" {
  depends_on = [module.lambda]
  for_each        = local.log_groups
  name            = "${module.lambda.lambda_function_name}-Subscription-${each.key}"
  log_group_name  = data.aws_cloudwatch_log_group.this[each.key].name
  destination_arn = module.lambda[0].lambda_function_arn
  filter_pattern  = ""
  }
  

resource "aws_sns_topic" "this" {
  for_each     = var.log_info
  name_prefix  = "${module.locals[each.key].function_name}-Failure"
  display_name = "${module.locals[each.key].function_name}-Failure"
  tags         = merge(var.tags, module.locals[each.key].tags)
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.store_api_key_in_secrets_manager ? 1 : 0
  name        = "lambda/coralogix/${data.aws_region.this.name}/${var.s3_bucket_name}/api_key"
  description = "Coralogix Send Your Data key Secret"
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.store_api_key_in_secrets_manager ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.api_key
}
resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this]
  for_each   = var.notification_email != null ? var.log_info : {}
  topic_arn  = aws_sns_topic.this[each.key].arn
  protocol   = "email"
  endpoint   = var.notification_email
}

resource "aws_lambda_permission" "sns_lambda_permission" {
  for_each      = var.sns_topic_name != null ? var.log_info : {}
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.locals[each.key].function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.sns_topic[0].arn
  depends_on    = [data.aws_sns_topic.sns_topic]
}

resource "aws_sns_topic_policy" "test" {
  count  = var.sns_topic_name != null ? 1 : 0
  arn    = data.aws_sns_topic.sns_topic[0].arn
  policy = data.aws_iam_policy_document.topic[0].json
}

resource "aws_sns_topic_subscription" "lambda_sns_subscription" {
  for_each   = var.sns_topic_name != null ? var.log_info : {}
  depends_on = [module.lambda]
  topic_arn  = data.aws_sns_topic.sns_topic[0].arn
  protocol   = "lambda"
  endpoint   = module.lambda[each.key].lambda_function_arn
}