module "locals" {
  source   = "../locals_variables"
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  integration_type = each.value.integration_type
  random_string    = random_string.this.result
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

module "lambda" {
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  depends_on             = [null_resource.s3_bucket_copy]
  source                 = "terraform-aws-modules/lambda/aws"
  function_name          = each.value.lambda_name == null ? module.locals[each.key].function_name : each.value.lambda_name
  description            = "Send logs to Coralogix."
  version                = "6.5.0"
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
    CORALOGIX_ENDPOINT = var.custom_domain != "" ? "https://ingress.${var.custom_domain}" : var.subnet_ids == null ? "https://ingress.${lookup(module.locals[each.key].coralogix_domains, var.coralogix_region, "Europe")}" : "https://ingress.private.${lookup(module.locals.coralogix_domains, var.coralogix_region, "Europe")}"
    INTEGRATION_TYPE   = each.value.integration_type
    RUST_LOG           = var.log_level
    CORALOGIX_API_KEY  = var.store_api_key_in_secrets_manager && !local.api_key_is_arn ? aws_secretsmanager_secret.coralogix_secret[0].arn : var.api_key
    APP_NAME           = each.value.application_name
    SUB_NAME           = each.value.subsystem_name
    NEWLINE_PATTERN    = var.integration_info != null ? each.value.newline_pattern : null
    BLOCKING_PATTERN   = var.blocking_pattern
    SAMPLING           = tostring(var.sampling_rate)
    ADD_METADATA       = var.add_metadata
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.name}" : var.custom_s3_bucket
    key    = "coralogix-aws-shipper.zip"
  }
  policy_path                             = "/coralogix/"
  role_path                               = "/coralogix/"
  role_name                               = each.value.lambda_name == null ? "${module.locals[each.key].function_name}-Role" : "${each.value.lambda_name}-Role"
  role_description                        = each.value.lambda_name == null ? "Role for ${module.locals[each.key].function_name} Lambda Function." : "Role for ${each.value.lambda_name} Lambda Function."
  cloudwatch_logs_retention_in_days       = each.value.lambda_log_retention
  create_current_version_allowed_triggers = false
  attach_policy_statements                = true
  create_role                             = var.msk_cluster_arn != null ? false : true
  lambda_role                             = var.msk_cluster_arn != null ? aws_iam_role.role_for_msk[0].arn : ""
  policy_statements = {
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
      resources = [aws_sns_topic.this[each.key].arn]
    }
    sqs_s3_integration_policy = var.sqs_name != null && var.s3_bucket_name != null ? {
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetObjectVersion",
        "s3:GetLifecycleConfiguration"
      ]
      resources = ["${data.aws_s3_bucket.this[0].arn}/*", data.aws_s3_bucket.this[0].arn]
    } : {
        effect = "Deny"
        actions = ["ecr:DescribeImageScanFindings"]
        resources = ["*"]
    } 
    integrations_policy = var.s3_bucket_name != null && var.sqs_name == null ? {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["${data.aws_s3_bucket.this[0].arn}/*"]
    } : var.sqs_name != null ? {
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [data.aws_sqs_queue.name[0].arn]
    }: var.kinesis_stream_name != null ? {
      effect = "Allow"
      actions = [
        "kinesis:GetRecords",
        "kinesis:GetShardIterator",
        "kinesis:DescribeStream",
        "kinesis:ListStreams",
        "kinesis:ListShards",
        "kinesis:DescribeStreamSummary",
        "kinesis:SubscribeToShard"
      ]
      resources = [data.aws_kinesis_stream.kinesis_stream[0].arn]
    } : var.kafka_brokers != null ? {
        effect = "Allow"
        actions = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        resources = ["*"]
    } : var.integration_type == "EcrScan" ? {
        effect = "Allow"
        actions = ["ecr:DescribeImageScanFindings"]
        resources = ["*"]
    } :  {
        effect = "Deny"
        actions = ["ecr:DescribeImageScanFindings"]
        resources = ["*"]
    }
  }

  allowed_triggers = var.s3_bucket_name != null && local.sns_enable != true ? {
    AllowExecutionFromS3 = {
      principal  = "s3.amazonaws.com"
      source_arn = data.aws_s3_bucket.this[0].arn
    }
    } : var.msk_cluster_arn != null ? {
    AllowExecutionFromMSK = {
      principal  = "kafka.amazonaws.com"
      source_arn = var.msk_cluster_arn
    }
  } : var.integration_type == "EcrScan" ?{
    AllowExecutionFromECR = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.EventBridgeRule[0].arn
    }
  }  :{}

  tags = merge(var.tags, module.locals[each.key].tags)
}

resource "aws_lambda_function_event_invoke_config" "invoke_on_failure" {
  for_each = {
    for key, integration_info in var.integration_info != null ? var.integration_info : local.integration_info : key => integration_info
    if var.notification_email != null
  }
  depends_on    = [module.lambda]
  function_name = each.value.lambda_name == null ? module.locals[each.key].function_name : each.value.lambda_name

  destination_config {
    on_failure {
      destination = aws_sns_topic.this[each.key].arn
    }
  }
}

resource "aws_sns_topic_subscription" "this" {
  depends_on = [aws_sns_topic.this]
  for_each = {
    for key, integration_info in var.integration_info != null ? var.integration_info : local.integration_info : key => integration_info
    if var.notification_email != null
  }
  topic_arn = aws_sns_topic.this[each.key].arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_lambda_permission" "sns_lambda_permission" {
  count         = local.sns_enable ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.sns_topic[count.index].arn
  depends_on    = [data.aws_sns_topic.sns_topic]
}

resource "aws_sns_topic_policy" "test" {
  count  = local.sns_enable && var.integration_type != "Sns" ? 1 : 0
  arn    = data.aws_sns_topic.sns_topic[count.index].arn
  policy = data.aws_iam_policy_document.topic[count.index].json
}


resource "aws_secretsmanager_secret" "coralogix_secret" {
  count       = var.store_api_key_in_secrets_manager && !local.api_key_is_arn ? 1 : 0
  name        = "lambda/coralogix/${data.aws_region.this.name}/coralogix-aws-shipper/coralogix-${random_string.this.result}"
  description = "Coralogix Send Your Data key Secret"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.store_api_key_in_secrets_manager && !local.api_key_is_arn ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.coralogix_secret]
  secret_id     = aws_secretsmanager_secret.coralogix_secret[0].id
  secret_string = var.api_key
}
