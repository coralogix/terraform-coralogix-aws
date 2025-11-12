module "locals" {
  source   = "../locals_variables"
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  integration_type = each.value.integration_type
  random_string    = random_string.this[each.key].result
}

resource "random_string" "this" {
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  length  = 6
  special = false
}

resource "random_string" "lambda_role" {
  count = var.execution_role_name == null ? 1 : 0

  length  = 6
  special = false
}

resource "null_resource" "s3_bucket_copy" {
  count = var.custom_s3_bucket == "" ? 0 : 1

  provisioner "local-exec" {
    # command = "curl -o coralogix-aws-shipper.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/coralogix-aws-shipper.zip ; aws s3 cp ./coralogix-aws-shipper.zip s3://coralogix-aws-shipper.zip ; rm ./coralogix-aws-shipper.zip"
    command = <<-EOF
      if [[ "${var.cpu_arch}" == "x86_64" ]]; then
        file_name="coralogix-aws-shipper-x86-64.zip"
      else
        file_name="coralogix-aws-shipper.zip"
      fi
      curl -o $file_name https://coralogix-serverless-repo-ap-east-1.s3.ap-east-1.amazonaws.com/$file_name
      aws s3 cp ./$file_name s3://${var.custom_s3_bucket}
      if [ -f $file_name ]; then
        rm ./$file_name
      else
        echo "Couldn't find $file_name, skip deleting"
      fi
    EOF
  }
}

resource "aws_iam_policy" "lambda_policy" {
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  name        = "policy-for-coralogix-lambda-${random_string.this[each.key].result}"
  description = "Policy for Lambda function ${each.value.lambda_name == null ? module.locals[each.key].function_name : each.value.lambda_name}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = concat(
      # CloudWatch Logs Policy
      [
        {
          Effect   = "Allow"
          Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
          Resource = ["*"]
        }
      ],

      # Secrets Access Policy
      each.value.store_api_key_in_secrets_manager == null || each.value.store_api_key_in_secrets_manager == true || local.api_key_is_arn ? [
        {
          Effect   = "Allow",
          Action   = ["secretsmanager:GetSecretValue"],
          Resource = local.api_key_is_arn ? [var.api_key] : [aws_secretsmanager_secret.coralogix_secret[each.key].arn]
        },
      ] : [],

      # Destination on Failure Policy
      var.notification_email != null ? [
        {
          Effect   = "Allow",
          Action   = ["sns:Publish"],
          Resource = [aws_sns_topic.this[each.key].arn]
        },
      ] : [],

      # Private Link Policy
      var.subnet_ids != null ? [
        {
          Effect   = "Allow",
          Action   = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DescribeVpcs", "ec2:DeleteNetworkInterface", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups"],
          Resource = ["*"]
        },
      ] : [],

      # SQS S3 Integration Policy
      var.sqs_name != null && local.s3_bucket_names != toset([]) ? [
        {
          Effect   = "Allow",
          Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
          Resource = [data.aws_sqs_queue.name[0].arn]
        },
        {
          Effect   = "Allow",
          Action   = ["s3:GetObject"],
          Resource = flatten([for bucket in data.aws_s3_bucket.this : ["${bucket.arn}/*", "${bucket.arn}"]])
        },
      ] : [],

      # SNS S3 Integration Policy
      var.sns_topic_name != null && local.s3_bucket_names != toset([]) ? [
        {
          Effect   = "Allow",
          Action   = ["sns:Publish"],
          Resource = [data.aws_sns_topic.sns_topic[0].arn]
        },
        {
          Effect   = "Allow",
          Action   = ["s3:GetObject"],
          Resource = flatten([for bucket in data.aws_s3_bucket.this : ["${bucket.arn}/*", "${bucket.arn}"]])
        },
      ] : [],

      # S3 Integration Policy
      local.s3_bucket_names != toset([]) && var.sqs_name == null && var.sns_topic_name == null ? [
        {
          Effect   = "Allow",
          Action   = ["s3:GetObject"],
          Resource = flatten([for bucket in data.aws_s3_bucket.this : ["${bucket.arn}/*", "${bucket.arn}"]])
        },
      ] : [],

      # SQS Integration Policy
      local.s3_bucket_names == toset([]) && var.sqs_name != null ? [
        {
          Effect   = "Allow",
          Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
          Resource = [data.aws_sqs_queue.name[0].arn]
        },
      ] : [],

      # SNS Integration Policy
      local.s3_bucket_names == toset([]) && var.sns_topic_name != null ? [
        {
          Effect   = "Allow",
          Action   = ["sns:Publish"]
          Resource = [data.aws_sns_topic.sns_topic[0].arn]
        },
      ] : [],

      # Kinesis Integration policy
      var.kinesis_stream_name != null ? [
        {
          Effect   = "Allow",
          Action   = ["kinesis:GetRecords", "kinesis:GetShardIterator", "kinesis:DescribeStream", "kinesis:ListStreams", "kinesis:ListShards", "kinesis:DescribeStreamSummary", "kinesis:SubscribeToShard"],
          Resource = [data.aws_kinesis_stream.kinesis_stream[0].arn]
        },
      ] : [],

      # Kafka Integration Policy
      var.kafka_brokers != null ? [
        {
          Effect   = "Allow",
          Action   = ["ec2:CreateNetworkInterface", "ec2:DescribeNetworkInterfaces", "ec2:DescribeVpcs", "ec2:DeleteNetworkInterface", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups"],
          Resource = ["*"]
        },
      ] : [],

      # DLQ Permissions
      var.enable_dlq ? [
        {
          Effect   = "Allow",
          Action   = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
          Resource = [aws_sqs_queue.DLQ[0].arn]
        },
        {
          Effect   = "Allow",
          Action   = ["s3:PutObject", "s3:PutObjectAcl", "s3:AbortMultipartUpload", "s3:DeleteObject", "s3:PutObjectTagging", "s3:PutObjectVersionTagging"]
          Resource = ["${data.aws_s3_bucket.dlq_bucket[0].arn}/*", data.aws_s3_bucket.dlq_bucket[0].arn]
        }
      ] : [],

      # EcrScan Integration Policy
      var.integration_type == "EcrScan" ? [
        {
          Effect   = "Allow"
          Action   = ["ecr:DescribeImageScanFindings"]
          Resource = ["*"]
        }
      ] : [],

      # S3 Bucket KMS Policy
      var.s3_bucket_kms_arn != null ? [
        {
          Effect   = "Allow",
          Action   = ["kms:Decrypt"],
          Resource = [var.s3_bucket_kms_arn]
        }
      ] : []
    )
  })
}

resource "aws_iam_role" "lambda_role" {
  count = var.execution_role_name == null ? 1 : 0
  name  = "Coralogix-lambda-role-${random_string.lambda_role[0].result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach the policy to the existing role
resource "aws_iam_role_policy_attachment" "attach_to_existing_role" {
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  role       = var.execution_role_name != null ? var.execution_role_name : aws_iam_role.lambda_role[0].name
  policy_arn = aws_iam_policy.lambda_policy[each.key].arn
}

resource "aws_iam_role_policy_attachment" "attach_msk_policy" {
  count      = var.msk_cluster_arn != null ? 1 : 0
  role       = var.execution_role_name != null ? var.execution_role_name : aws_iam_role.lambda_role[0].name
  policy_arn = data.aws_iam_policy.AWSLambdaMSKExecutionRole[0].arn
}

module "lambda" {
  for_each = var.integration_info != null ? var.integration_info : local.integration_info

  depends_on                     = [null_resource.s3_bucket_copy, aws_sqs_queue.DLQ, aws_secretsmanager_secret.coralogix_secret]
  source                         = "terraform-aws-modules/lambda/aws"
  function_name                  = each.value.lambda_name == null ? module.locals[each.key].function_name : each.value.lambda_name
  description                    = "Send logs to Coralogix."
  version                        = "8.1.2"
  handler                        = "bootstrap"
  runtime                        = var.runtime
  architectures                  = [var.cpu_arch]
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions
  create_package                 = false
  destination_on_failure         = var.notification_email != null ? aws_sns_topic.this[each.key].arn : null
  vpc_subnet_ids                 = var.subnet_ids
  vpc_security_group_ids         = var.security_group_ids
  dead_letter_target_arn         = var.enable_dlq ? aws_sqs_queue.DLQ[0].arn : null
  environment_variables = {
    CORALOGIX_ENDPOINT = var.custom_domain != "" ? "https://ingress.${var.custom_domain}" : var.subnet_ids == null ? "https://ingress.${lookup(module.locals[each.key].coralogix_domains, var.coralogix_region, "EU1")}" : "https://ingress.private.${lookup(module.locals[each.key].coralogix_domains, var.coralogix_region, "EU1")}"
    INTEGRATION_TYPE   = each.value.integration_type
    RUST_LOG           = var.log_level
    CORALOGIX_API_KEY  = !local.api_key_is_arn && (each.value.store_api_key_in_secrets_manager == null || each.value.store_api_key_in_secrets_manager == true) ? aws_secretsmanager_secret.coralogix_secret[each.key].arn : each.value.api_key
    APP_NAME           = each.value.application_name
    SUB_NAME           = each.value.subsystem_name
    NEWLINE_PATTERN    = each.value.newline_pattern != null ? each.value.newline_pattern : null
    BLOCKING_PATTERN   = var.blocking_pattern
    SAMPLING           = tostring(var.sampling_rate)
    ADD_METADATA       = var.add_metadata
    CUSTOM_METADATA    = var.custom_metadata
    CUSTOM_CSV_HEADER  = var.custom_csv_header
    DLQ_ARN            = var.enable_dlq ? aws_sqs_queue.DLQ[0].arn : null
    DLQ_RETRY_LIMIT    = var.enable_dlq ? var.dlq_retry_limit : null
    DLQ_S3_BUCKET      = var.enable_dlq ? var.dlq_s3_bucket : null
    DLQ_URL            = var.enable_dlq ? aws_sqs_queue.DLQ[0].url : null
    ASSUME_ROLE_ARN    = var.lambda_assume_role_arn
    TELEMETRY_MODE     = var.telemetry_mode
    BATCH_METRICS      = var.telemetry_mode == "metrics" && var.batch_metrics ? "1" : null
    METRICS_BATCH_MAX_SIZE = var.telemetry_mode == "metrics" && var.batch_metrics ? tostring(var.metrics_batch_max_size) : null
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.id}" : var.custom_s3_bucket
    key    = var.cpu_arch == "arm64" ? "coralogix-aws-shipper${var.source_code_version != "" ? "-${var.cpu_arch}-${var.source_code_version}" : ""}.zip" : "coralogix-aws-shipper-x86-64${var.source_code_version != "" ? "-${var.cpu_arch}-${var.source_code_version}" : ""}.zip"
  }
  cloudwatch_logs_retention_in_days       = each.value.lambda_log_retention
  create_current_version_allowed_triggers = false
  attach_policy_statements                = false
  create_role                             = false
  lambda_role                             = var.execution_role_name != null ? data.aws_iam_role.LambdaExecutionRole[0].arn : aws_iam_role.lambda_role[0].arn
  allowed_triggers = local.s3_bucket_names != toset([]) && local.sns_enable != true ? {
    for bucket in data.aws_s3_bucket.this : "AllowExecutionFromS3_${replace(bucket.bucket, ".", "_")}" => {
      principal  = "s3.amazonaws.com"
      source_arn = bucket.arn
    }
    } : var.msk_cluster_arn != null ? {
    AllowExecutionFromMSK = {
      principal  = "kafka.amazonaws.com"
      source_arn = var.msk_cluster_arn
    }
    } : var.integration_type == "EcrScan" ? {
    AllowExecutionFromECR = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.EventBridgeRule[0].arn
    }
  } : {}

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
  count  = local.sns_enable && var.integration_type != "Sns" && var.create_sns_topic_policy ? 1 : 0
  arn    = data.aws_sns_topic.sns_topic[count.index].arn
  policy = data.aws_iam_policy_document.topic[count.index].json
}


resource "aws_secretsmanager_secret" "coralogix_secret" {
  for_each = {
    for key, integration_info in var.integration_info != null ? var.integration_info : local.integration_info : key => integration_info
    if !local.api_key_is_arn && (integration_info.store_api_key_in_secrets_manager == null || integration_info.store_api_key_in_secrets_manager == true)
  }
  name        = "lambda/coralogix/${data.aws_region.this.id}/coralogix-aws-shipper/coralogix-${random_string.this[each.key].result}"
  description = "Coralogix Send Your Data key Secret"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "service_user" {
  for_each = {
    for key, integration_info in var.integration_info != null ? var.integration_info : local.integration_info : key => integration_info
    if !local.api_key_is_arn && (integration_info.store_api_key_in_secrets_manager == null || integration_info.store_api_key_in_secrets_manager == true)
  }
  depends_on    = [aws_secretsmanager_secret.coralogix_secret]
  secret_id     = aws_secretsmanager_secret.coralogix_secret[each.key].id
  secret_string = each.value.api_key
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = (var.store_api_key_in_secrets_manager || local.api_key_is_arn) && var.subnet_ids != null && var.create_endpoint ? 1 : 0
  vpc_id              = data.aws_subnet.subnet[0].vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.id}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = true
}

resource "aws_sqs_queue" "DLQ" {
  count                      = var.enable_dlq ? 1 : 0
  name                       = "coralogix-aws-shipper-dlq-${random_string.lambda_role[0].result}"
  message_retention_seconds  = 1209600
  delay_seconds              = var.dlq_retry_delay
  visibility_timeout_seconds = var.timeout
}

resource "aws_lambda_event_source_mapping" "dlq_sqs" {
  depends_on       = [module.lambda]
  count            = var.enable_dlq ? 1 : 0
  event_source_arn = aws_sqs_queue.DLQ[0].arn
  function_name    = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  enabled          = true
}
