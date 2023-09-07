locals {
  #  sns_enable               = var.integration_type == "s3-sns" || var.integration_type == "cloudtrail-sns" ? true : false
  default_newline          = "(?:\\r\\n|\\r|\\n)"
  default_blocking_pattern = ""
}

module "locals" {
  for_each = var.log_info
  source   = "../locals_variables"

  integration_type = each.value.integration_type
  random_string    = "${each.key}-${random_string.this.result}"
}

data "aws_region" "this" {}

data "aws_caller_identity" "this" {}

data "aws_s3_bucket" "this" {
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
  create                 = var.layer_arn == "" ? true : false
  depends_on             = [null_resource.s3_bucket_copy]
  source                 = "terraform-aws-modules/lambda/aws"
  version                = "3.2.1"
  function_name          = module.locals[each.key].function_name
  description            = "Send logs from S3 bucket to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this[each.key].arn
  environment_variables = {
    CORALOGIX_URL         = var.custom_url == "" ? "https://${lookup(module.locals[each.key].coralogix_regions, var.coralogix_region, "Europe")}${module.locals[each.key].coralogix_url_seffix}" : var.custom_url
    CORALOGIX_BUFFER_SIZE = tostring(var.buffer_size)
    private_key           = var.private_key
    app_name              = each.value.application_name
    sub_name              = each.value.subsystem_name
    newline_pattern       = each.value.newline_pattern == null ? local.default_newline : each.value.newline_pattern
    blocking_pattern      = each.value.blocking_pattern == null ? local.default_newline : each.value.blocking_pattern
    sampling              = tostring(var.sampling_rate)
    debug                 = tostring(var.debug)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "${each.value.integration_type}.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals[each.key].function_name}-Role"
  role_description                        = "Role for ${module.locals[each.key].function_name} Lambda Function."
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
  allowed_triggers = var.sns_topic_name == null ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this.arn
    }
  } : {}

  tags = merge(var.tags, module.locals[each.key].tags)
}

module "lambdaSSM" {
  for_each               = var.log_info
  source                 = "terraform-aws-modules/lambda/aws"
  create                 = var.layer_arn != "" ? true : false
  depends_on             = [null_resource.s3_bucket_copy]
  version                = "3.2.1"
  layers                 = [var.layer_arn]
  function_name          = module.locals[each.key].function_name
  description            = "Send logs from S3 bucket to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs16.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this[each.key].arn
  environment_variables = {
    CORALOGIX_URL           = var.custom_url == "" ? "https://${lookup(module.locals[each.key].coralogix_regions, var.coralogix_region, "Europe")}${module.locals[each.key].coralogix_url_seffix}" : var.custom_url
    CORALOGIX_BUFFER_SIZE   = tostring(var.buffer_size)
    AWS_LAMBDA_EXEC_WRAPPER = "/opt/wrapper.sh"
    SECRET_NAME             = var.create_secret == "False" ? var.private_key : ""
    app_name                = each.value.application_name
    sub_name                = each.value.subsystem_name
    newline_pattern         = each.value.newline_pattern == null ? local.default_newline : each.value.newline_pattern
    blocking_pattern        = each.value.blocking_pattern == null ? local.default_newline : each.value.blocking_pattern
    sampling                = tostring(var.sampling_rate)
    debug                   = tostring(var.debug)
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "${each.value.integration_type}.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = "${module.locals[each.key].function_name}-Role"
  role_description                        = "Role for ${module.locals[each.key].function_name} Lambda Function."
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
      resources = [
        "arn:aws:secretsmanager:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:secret:lambda/coralogix/${data.aws_region.this.name}/${var.s3_bucket_name}/api_key-*"
      ]
    }
  }
  allowed_triggers = var.sns_topic_name == null ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this.arn
    }
  } : {}
  tags = merge(var.tags, module.locals[each.key].tags)
}

resource "aws_s3_bucket_notification" "lambda_notification" {
  count  = var.sns_topic_name == null ? 1 : 0
  bucket = data.aws_s3_bucket.this.bucket
  dynamic "lambda_function" {
    for_each = var.log_info
    iterator = log_info
    content {
      lambda_function_arn = var.layer_arn != "" ? module.lambdaSSM[log_info.key].lambda_function_arn : module.lambda[log_info.key].lambda_function_arn
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

resource "aws_sns_topic" "this" {
  for_each     = var.log_info
  name_prefix  = "${module.locals[each.key].function_name}-Failure"
  display_name = "${module.locals[each.key].function_name}-Failure"
  tags         = merge(var.tags, module.locals[each.key].tags)
}

resource "aws_secretsmanager_secret" "private_key_secret" {
  count       = var.layer_arn != "" && var.create_secret == "True" ? 1 : 0
  depends_on  = [module.lambdaSSM]
  name        = "lambda/coralogix/${data.aws_region.this.name}/${var.s3_bucket_name}/api_key"
  description = "Coralogix Send Your Data key Secret"
}
resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.layer_arn != "" && var.create_secret == "True" ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.private_key_secret]
  secret_id     = aws_secretsmanager_secret.private_key_secret[count.index].id
  secret_string = var.private_key
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
  depends_on = [module.lambdaSSM, module.lambda]
  topic_arn  = data.aws_sns_topic.sns_topic[0].arn
  protocol   = "lambda"
  endpoint   = var.layer_arn != "" ? module.lambdaSSM[each.key].lambda_function_arn : module.lambda[each.key].lambda_function_arn
}
