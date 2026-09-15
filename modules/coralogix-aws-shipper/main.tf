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

resource "random_string" "id" {
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
      local.needs_coralogix_api_key && (each.value.store_api_key_in_secrets_manager == null || each.value.store_api_key_in_secrets_manager == true || local.api_key_is_arn) ? [
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
      ] : [],

      # SNS failure-notification topic KMS Policy
      var.sns_kms_key_arn != null ? [
        {
          Effect   = "Allow",
          Action   = ["kms:Decrypt", "kms:GenerateDataKey*"],
          Resource = [var.sns_kms_key_arn]
        }
      ] : [],

      # Starlark S3 Script Policy
      startswith(var.starlark_script, "s3://") ? [
        {
          Effect   = "Allow",
          Action   = ["s3:GetObject"],
          Resource = ["${local.arn_prefix}:s3:::${local.starlark_s3_bucket}/*"]
        }
      ] : [],

      # X-Ray tracing permissions (required when Active tracing is enabled)
      var.tracing_mode == "Active" ? [
        {
          Effect   = "Allow"
          Action   = ["xray:PutTraceSegments", "xray:PutTelemetryRecords", "xray:GetSamplingRules", "xray:GetSamplingTargets"]
          Resource = ["*"]
        }
      ] : [],

      # Metrics stream tag enrichment (Resource Groups Tagging API + service reads used by YACE-style associator)
      var.telemetry_mode == "metrics" && var.metrics_tag_enrichment_enabled ? [
        {
          Effect = "Allow"
          Action = [
            "tag:GetResources",
            "cloudwatch:GetMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "apigateway:GET",
            "aps:ListWorkspaces",
            "autoscaling:DescribeAutoScalingGroups",
            "dms:DescribeReplicationInstances",
            "dms:DescribeReplicationTasks",
            "ec2:DescribeTransitGatewayAttachments",
            "ec2:DescribeSpotFleetRequests",
            "shield:ListProtections",
            "storagegateway:ListGateways",
            "storagegateway:ListTagsForResource",
            "iam:ListAccountAliases",
          ]
          Resource = ["*"]
        }
      ] : [],
    )
  })
}

resource "aws_iam_role" "lambda_role" {
  count = local.effective_create_role ? 1 : 0
  name  = "Coralogix-lambda-role-${random_string.id.result}"
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

  role       = local.lambda_role_name
  policy_arn = aws_iam_policy.lambda_policy[each.key].arn
}

resource "aws_iam_role_policy_attachment" "attach_msk_policy" {
  count      = !local.is_traces && var.msk_cluster_arn != null ? 1 : 0
  role       = local.lambda_role_name
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
  tracing_mode                   = var.tracing_mode
  dead_letter_target_arn         = var.enable_dlq ? aws_sqs_queue.DLQ[0].arn : null
  environment_variables = {
    CORALOGIX_ENDPOINT = local.needs_coralogix_rest_endpoint ? (
      var.custom_domain != "" ? "https://ingress.${var.custom_domain}" : (
        var.subnet_ids == null
        ? "https://ingress.${lookup(module.locals[each.key].coralogix_domains, var.coralogix_region, "EU1")}"
        : "https://ingress.private.${lookup(module.locals[each.key].coralogix_domains, var.coralogix_region, "EU1")}"
      )
    ) : null
    INTEGRATION_TYPE = each.value.integration_type
    RUST_LOG         = var.log_level
    CORALOGIX_API_KEY = local.needs_coralogix_api_key ? (
      !local.api_key_is_arn && (each.value.store_api_key_in_secrets_manager == null || each.value.store_api_key_in_secrets_manager == true)
      ? aws_secretsmanager_secret.coralogix_secret[each.key].arn
      : each.value.api_key
    ) : null
    LOG_EXPORT_PROTOCOL            = var.telemetry_mode == "logs" ? var.log_export_protocol : null
    OTLP_ENDPOINT                  = local.use_collector_otlp_logs || local.use_collector_otlp_traces ? var.otlp_endpoint : null
    DISABLE_LOG_SEVERITY_DETECTION = var.telemetry_mode == "logs" ? tostring(var.disable_log_severity_detection) : null
    CORALOGIX_DOMAIN = local.use_coralogix_otlp_logs || local.use_coralogix_otlp_traces ? (
      var.custom_domain != ""
      ? var.custom_domain
      : lookup(module.locals[each.key].coralogix_domains, var.coralogix_region, "eu1.coralogix.com")
    ) : null
    APP_NAME                       = each.value.application_name
    SUB_NAME                       = each.value.subsystem_name
    NEWLINE_PATTERN                = each.value.newline_pattern != null ? each.value.newline_pattern : null
    BLOCKING_PATTERN               = var.blocking_pattern
    SAMPLING                       = tostring(var.sampling_rate)
    ADD_METADATA                   = var.add_metadata
    CUSTOM_METADATA                = var.custom_metadata
    CUSTOM_CSV_HEADER              = var.custom_csv_header
    DLQ_ARN                        = var.enable_dlq ? aws_sqs_queue.DLQ[0].arn : null
    DLQ_RETRY_LIMIT                = var.enable_dlq ? var.dlq_retry_limit : null
    DLQ_S3_BUCKET                  = var.enable_dlq ? var.dlq_s3_bucket : null
    DLQ_URL                        = var.enable_dlq ? aws_sqs_queue.DLQ[0].url : null
    ASSUME_ROLE_ARN                = var.lambda_assume_role_arn
    TELEMETRY_MODE                 = var.telemetry_mode
    BATCH_METRICS                  = var.telemetry_mode == "metrics" && var.batch_metrics ? "1" : null
    METRICS_BATCH_MAX_SIZE         = var.telemetry_mode == "metrics" && var.batch_metrics ? tostring(var.metrics_batch_max_size) : null
    METRICS_TAG_ENRICHMENT_ENABLED = var.telemetry_mode == "metrics" ? (var.metrics_tag_enrichment_enabled ? "true" : "false") : null
    CONTINUE_ON_RESOURCE_FAILURE   = var.telemetry_mode == "metrics" ? (var.metrics_continue_on_resource_failure ? "true" : "false") : null
    FILE_CACHE_ENABLED             = var.telemetry_mode == "metrics" ? (var.metrics_file_cache_enabled ? "true" : "false") : null
    FILE_CACHE_PATH                = var.telemetry_mode == "metrics" ? var.metrics_file_cache_path : null
    FILE_CACHE_EXPIRATION          = var.telemetry_mode == "metrics" ? var.metrics_file_cache_expiration : null
    STARLARK_SCRIPT                = var.starlark_script != "" ? var.starlark_script : null
    LOG_STREAM_FILTER              = var.log_stream_filter != "" ? var.log_stream_filter : null
    ENABLE_AWS_FIPS                = var.govcloud_deployment ? (var.enable_aws_fips == null ? "true" : tostring(var.enable_aws_fips)) : null
    AWS_USE_FIPS_ENDPOINT          = var.govcloud_deployment ? (var.aws_use_fips_endpoint == null ? "true" : tostring(var.aws_use_fips_endpoint)) : null
  }
  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.id}" : var.custom_s3_bucket
    key    = var.cpu_arch == "arm64" ? "coralogix-aws-shipper${var.source_code_version != "" ? "-${var.cpu_arch}-${var.source_code_version}" : ""}.zip" : "coralogix-aws-shipper-x86-64${var.source_code_version != "" ? "-${var.cpu_arch}-${var.source_code_version}" : ""}.zip"
  }
  cloudwatch_logs_retention_in_days       = each.value.lambda_log_retention
  create_current_version_allowed_triggers = false
  attach_policy_statements                = false
  create_role                             = false
  lambda_role                             = local.lambda_role_arn
  # is_traces first: the S3, MSK and ECR branches below reference resources that are
  # gated off in traces mode, so the chain has to agree with them.
  allowed_triggers = local.is_traces ? {} : local.s3_bucket_names != toset([]) && local.sns_enable != true ? {
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

# Safety comes from local.is_traces, which every trigger-creating resource is gated on,
# so an event source cannot be attached in traces mode by setting its own variable. These
# preconditions exist to say so out loud: without them a leftover sqs_name or
# kinesis_stream_name would be silently dropped rather than explained. They are a
# courtesy, not the mechanism - an input missed here no longer creates a broken
# deployment, which is why the previous enumerate-every-input approach kept springing
# leaks as each fix moved which variable was authoritative.
#
# Preconditions rather than a check block: a check only warns.
#
# subnet_ids is deliberately not restricted. It means "run in a VPC", not "no public
# egress" - a subnet with a NAT gateway reaches the Coralogix ingress fine, and the
# module does not restrict direct OTLP logs either. Reaching the endpoint is the
# deployer's concern, documented in the README.
resource "terraform_data" "traces_mode_guardrails" {
  count = var.telemetry_mode == "traces" ? 1 : 0

  lifecycle {
    precondition {
      condition     = var.integration_type == "CloudWatch"
      error_message = "integration_type must be CloudWatch when telemetry_mode is traces."
    }
    # integration_info deploys one lambda per entry, but traces has a single log group,
    # so extra entries would only stack subscription filters on aws/spans. Rejecting it
    # also keeps two module-wide assumptions true: CloudWatch.tf addresses the entry by
    # the literal key "integration", and api_key_is_arn reads only the top-level
    # api_key - a per-entry ARN would be wrapped in a new secret the lambda cannot read.
    # 1.4.15 and earlier do not recognise TELEMETRY_MODE=traces: the shipper falls
    # through to its logs path and ships span records as log lines. An unpinned
    # source_code_version tracks the latest artifact and is always fine.
    precondition {
      condition     = var.source_code_version == "" || coalesce(local.source_code_version_number, 0) >= 1004016
      error_message = "telemetry_mode = \"traces\" requires shipper 1.4.16 or later; set source_code_version to 1.4.16 or above, or leave it empty to track the latest."
    }
    precondition {
      condition     = var.integration_info == null
      error_message = "integration_info is not supported when telemetry_mode is traces; configure the single aws/spans integration with the top-level variables."
    }
    precondition {
      condition     = var.log_groups != null && length(var.log_groups) == 1 && contains(var.log_groups, "aws/spans")
      error_message = "log_groups must be exactly [\"aws/spans\"] when telemetry_mode is traces."
    }
    precondition {
      condition     = var.kinesis_stream_name == null && var.kafka_brokers == null && var.msk_topic_name == null && var.msk_cluster_arn == null
      error_message = "Kinesis, Kafka and MSK triggers are not supported when telemetry_mode is traces."
    }
    precondition {
      condition     = var.s3_bucket_name == null && var.sns_topic_name == null && var.sqs_name == null
      error_message = "S3, SNS and SQS triggers are not supported when telemetry_mode is traces."
    }
    # The invoke permission is built from log_group_prefix when it is set, while the
    # subscription filter always comes from log_groups - a prefix not covering aws/spans
    # leaves the subscription without a permission and the apply fails.
    precondition {
      condition     = var.log_group_prefix == null
      error_message = "log_group_prefix is not supported when telemetry_mode is traces; the aws/spans subscription needs its invoke permission to come from log_groups."
    }
    precondition {
      condition     = !var.enable_dlq
      error_message = "enable_dlq is not supported when telemetry_mode is traces: the dead-letter queue is mapped back to the lambda, so replays arrive as SQS events that the traces handler cannot read."
    }
    precondition {
      condition = var.otlp_endpoint != "" || alltrue([
        for integration in values(local.integration_info) :
        integration.api_key != null && integration.api_key != ""
      ])
      error_message = "Direct Coralogix OTLP traces require an api_key; set otlp_endpoint to use a Collector instead."
    }
    # The domain map has no Custom key, so lookup falls back to eu1.coralogix.com and a
    # custom cluster would silently receive nothing.
    precondition {
      condition     = var.otlp_endpoint != "" || var.coralogix_region != "Custom" || var.custom_domain != ""
      error_message = "Direct Coralogix OTLP traces with coralogix_region = \"Custom\" require custom_domain."
    }
  }
}

check "direct_otlp_requires_credentials" {
  assert {
    condition = !local.use_coralogix_otlp_logs || (
      alltrue([
        for integration in values(local.integration_info) :
        integration.api_key != null && integration.api_key != ""
      ]) &&
      (var.coralogix_region != "Custom" || var.custom_domain != "")
    )
    error_message = "Direct Coralogix OTLP requires api_key and either a non-Custom coralogix_region or custom_domain."
  }
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
  count         = !local.is_traces && local.sns_enable ? 1 : 0
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.aws_sns_topic.sns_topic[count.index].arn
  depends_on    = [data.aws_sns_topic.sns_topic]
}

resource "aws_sns_topic_policy" "test" {
  count  = !local.is_traces && local.sns_enable && var.integration_type != "Sns" && var.create_sns_topic_policy ? 1 : 0
  arn    = data.aws_sns_topic.sns_topic[count.index].arn
  policy = data.aws_iam_policy_document.topic[count.index].json
}


resource "aws_secretsmanager_secret" "coralogix_secret" {
  for_each = {
    for key, integration_info in var.integration_info != null ? var.integration_info : local.integration_info : key => integration_info
    if local.needs_coralogix_api_key && !local.api_key_is_arn && (integration_info.store_api_key_in_secrets_manager == null || integration_info.store_api_key_in_secrets_manager == true)
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
    if local.needs_coralogix_api_key && !local.api_key_is_arn && (integration_info.store_api_key_in_secrets_manager == null || integration_info.store_api_key_in_secrets_manager == true)
  }
  depends_on    = [aws_secretsmanager_secret.coralogix_secret]
  secret_id     = aws_secretsmanager_secret.coralogix_secret[each.key].id
  secret_string = each.value.api_key
}

resource "aws_vpc_endpoint" "secretsmanager" {
  count               = local.needs_coralogix_api_key && (var.store_api_key_in_secrets_manager || local.api_key_is_arn) && var.subnet_ids != null && var.create_endpoint ? 1 : 0
  vpc_id              = data.aws_subnet.subnet[0].vpc_id
  service_name        = "com.amazonaws.${data.aws_region.this.id}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.subnet_ids
  security_group_ids  = var.security_group_ids
  private_dns_enabled = true
}

resource "aws_sqs_queue" "DLQ" {
  count                      = var.enable_dlq ? 1 : 0
  name                       = "coralogix-aws-shipper-dlq-${random_string.id.result}"
  message_retention_seconds  = 1209600
  delay_seconds              = var.dlq_retry_delay
  visibility_timeout_seconds = var.timeout
}

resource "aws_lambda_event_source_mapping" "dlq_sqs" {
  depends_on       = [module.lambda]
  count            = !local.is_traces && var.enable_dlq ? 1 : 0
  event_source_arn = aws_sqs_queue.DLQ[0].arn
  function_name    = local.integration_info.integration.lambda_name == null ? module.locals.integration.function_name : local.integration_info.integration.lambda_name
  enabled          = true
}
