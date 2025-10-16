locals {
  function_name = "Coralogix-${var.package_name}-${random_string.this.result}"
  coralogix_regions = {
    EU1    = "ingress.eu1.coralogix.com:443"
    EU2    = "ingress.eu2.coralogix.com:443"
    AP1    = "ingress.ap1.coralogix.com:443"
    AP2    = "ingress.ap2.coralogix.com:443"
    AP3    = "ingress.ap3.coralogix.com:443"
    US1    = "ingress.us1.coralogix.com:443"
    US2    = "ingress.us2.coralogix.com:443"
    Custom = var.custom_url
  }
  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }
}

data "aws_region" "this" {}
data "aws_caller_identity" "current" {}

resource "aws_sqs_queue" "metadata_queue" {
  name                       = "${local.function_name}-metadata-queue"
  visibility_timeout_seconds = 900
  message_retention_seconds  = var.resource_ttl_minutes * 60
  tags                       = merge(var.tags, local.tags)
}

data "aws_iam_policy_document" "metadata_queue" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.metadata_queue.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [var.organization_id]
    }
  }
}

resource "aws_sqs_queue_policy" "metadata_queue" {
  count     = var.organization_id != "" ? 1 : 0
  queue_url = aws_sqs_queue.metadata_queue.url
  policy    = data.aws_iam_policy_document.metadata_queue.json
}

module "eventbridge" {
  source      = "terraform-aws-modules/eventbridge/aws"
  version     = "3.17.1"
  create_bus  = false
  create_role = false

  rules = {
    crons = {
      description         = "Trigger for a Lambda"
      schedule_expression = var.schedule
    }
  }

  targets = {
    crons = [
      {
        name  = "cron-for-lambda"
        arn   = module.collector_lambda.lambda_function_arn
        input = jsonencode({ "job" : "cron-by-rate" })
      }
    ]
  }
}

resource "random_string" "this" {
  length  = 12
  special = false
}

resource "null_resource" "s3_bucket" {
  count = var.custom_s3_bucket == "" ? 0 : 1
  provisioner "local-exec" {
    command = "curl -o ${var.package_name}-collector.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/${var.package_name}-collector.zip ; aws s3 cp ./${var.package_name}-collector.zip s3://${var.custom_s3_bucket} ; rm ./${var.package_name}-collector.zip"
  }

  provisioner "local-exec" {
    command = "curl -o ${var.package_name}-generator.zip https://coralogix-serverless-repo-eu-central-1.s3.eu-central-1.amazonaws.com/${var.package_name}-generator.zip ; aws s3 cp ./${var.package_name}-generator.zip s3://${var.custom_s3_bucket} ; rm ./${var.package_name}-generator.zip"
  }
}

module "collector_lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  depends_on             = [null_resource.s3_bucket]
  version                = "7.20.1"
  publish                = true
  function_name          = "${local.function_name}-collector"
  description            = "Collect AWS resource metadata for Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs22.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn

  environment_variables = {
    LAMBDA_FUNCTION_INCLUDE_REGEX_FILTER = var.lambda_function_include_regex_filter
    LAMBDA_FUNCTION_EXCLUDE_REGEX_FILTER = var.lambda_function_exclude_regex_filter
    LAMBDA_FUNCTION_TAG_FILTERS          = var.lambda_function_tag_filters
    REGIONS                              = length(var.source_regions) > 0 ? join(",", var.source_regions) : null
    CROSSACCOUNT_MODE                    = var.crossaccount_mode
    CROSSACCOUNT_IAM_ACCOUNTIDS          = length(var.crossaccount_account_ids) > 0 ? join(",", var.crossaccount_account_ids) : null
    CROSSACCOUNT_IAM_ROLENAME            = length(var.crossaccount_iam_role_name) > 0 ? var.crossaccount_iam_role_name : null
    CROSSACCOUNT_CONFIG_AGGREGATOR       = length(var.crossaccount_config_aggregator) > 0 ? var.crossaccount_config_aggregator : null
    AWS_RETRY_MODE                       = "adaptive"
    AWS_MAX_ATTEMPTS                     = 10
    IS_EC2_RESOURCE_TYPE_EXCLUDED        = var.excluded_ec2_resource_type
    IS_LAMBDA_RESOURCE_TYPE_EXCLUDED     = var.excluded_lambda_resource_type
    METADATA_QUEUE_URL                   = aws_sqs_queue.metadata_queue.url
  }

  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.id}" : var.custom_s3_bucket
    key    = "${var.package_name}-collector.zip"
  }

  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect = "Allow"
      actions = [
        "ec2:DescribeInstances"
      ]
      resources = ["*"]
    }
    lambda = {
      effect = "Allow"
      actions = [
        "lambda:ListFunctions"
      ]
      resources = ["*"]
    }
    tags = {
      effect = "Allow"
      actions = [
        "tag:GetResources"
      ]
      resources = ["*"]
    }
    sqs = {
      effect = "Allow"
      actions = [
        "sqs:SendMessage"
      ]
      resources = [aws_sqs_queue.metadata_queue.arn]
    }
    assume_role = var.crossaccount_mode == "StaticIAM" ? {
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]
      resources = ["arn:aws:iam::*:role/${var.crossaccount_iam_role_name}"]
    } : null
    config = var.crossaccount_mode == "Config" ? {
      effect = "Allow"
      actions = [
        "config:SelectAggregateResourceConfig"
      ]
      resources = ["*"]
    } : null
  }

  allowed_triggers = {
    EventBridge = {
      principal  = "events.amazonaws.com"
      source_arn = module.eventbridge.eventbridge_rule_arns["crons"]
    }
  }

  tags = merge(var.tags, local.tags)
}

module "generator_lambda" {
  source                 = "terraform-aws-modules/lambda/aws"
  depends_on             = [null_resource.s3_bucket]
  version                = "7.20.1"
  publish                = true
  create                 = var.secret_manager_enabled == false ? true : false
  function_name          = "${local.function_name}-generator"
  description            = "Generate and send resource metadata to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs22.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn

  environment_variables = {
    CORALOGIX_METADATA_URL       = lookup(local.coralogix_regions, var.coralogix_region, "EU1")
    CROSSACCOUNT_IAM_ROLENAME    = length(var.crossaccount_iam_role_name) > 0 ? var.crossaccount_iam_role_name : null
    LAMBDA_LAYER_FILTER          = var.lambda_telemetry_exporter_filter ? "True" : "False"
    private_key                  = var.api_key
    LATEST_VERSIONS_PER_FUNCTION = var.latest_versions_per_function
    COLLECT_ALIASES              = var.collect_aliases == true ? "True" : "False"
    RESOURCE_TTL_MINUTES         = var.resource_ttl_minutes
    AWS_RETRY_MODE               = "adaptive"
    AWS_MAX_ATTEMPTS             = 10
  }

  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.id}" : var.custom_s3_bucket
    key    = "${var.package_name}-generator.zip"
  }

  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect = "Allow"
      actions = [
        "ec2:DescribeInstances"
      ]
      resources = ["*"]
    }
    lambda = {
      effect = "Allow"
      actions = [
        "lambda:ListVersionsByFunction",
        "lambda:GetFunctionConfiguration",
        "lambda:GetFunctionConcurrency",
        "lambda:ListTags",
        "lambda:ListAliases",
        "lambda:ListEventSourceMappings",
        "lambda:GetPolicy"
      ]
      resources = ["*"]
    }
    sqs = {
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [aws_sqs_queue.metadata_queue.arn]
    }
    assume_role = var.crossaccount_mode == "Disabled" ? null : {
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]
      resources = ["arn:aws:iam::*:role/${var.crossaccount_iam_role_name}"]
    }
  }

  allowed_triggers = {
    SQS = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.metadata_queue.arn
    }
  }

  create_current_version_allowed_triggers = true
  event_source_mapping = {
    sqs = {
      event_source_arn = aws_sqs_queue.metadata_queue.arn
      batch_size       = 1
      scaling_config = {
        maximum_concurrency = var.maximum_concurrency
      }
    }
  }

  tags = merge(var.tags, local.tags)
}

module "generator_lambda_sm" {
  source                 = "terraform-aws-modules/lambda/aws"
  depends_on             = [null_resource.s3_bucket]
  version                = "7.20.1"
  publish                = true
  create                 = var.secret_manager_enabled ? true : false
  function_name          = "${local.function_name}-generator"
  description            = "Generate and send resource metadata to Coralogix."
  handler                = "index.handler"
  runtime                = "nodejs22.x"
  architectures          = [var.architecture]
  memory_size            = var.memory_size
  timeout                = var.timeout
  create_package         = false
  destination_on_failure = aws_sns_topic.this.arn
  layers                 = [var.layer_arn]

  environment_variables = {
    CORALOGIX_METADATA_URL       = lookup(local.coralogix_regions, var.coralogix_region, "EU1")
    CROSSACCOUNT_IAM_ROLENAME    = length(var.crossaccount_iam_role_name) > 0 ? var.crossaccount_iam_role_name : null
    LAMBDA_LAYER_FILTER          = var.lambda_telemetry_exporter_filter ? "True" : "False"
    AWS_LAMBDA_EXEC_WRAPPER      = "/opt/wrapper.sh"
    SECRET_NAME                  = var.create_secret == false ? var.api_key : ""
    LATEST_VERSIONS_PER_FUNCTION = var.latest_versions_per_function
    COLLECT_ALIASES              = var.collect_aliases == true ? "True" : "False"
    RESOURCE_TTL_MINUTES         = var.resource_ttl_minutes
    AWS_RETRY_MODE               = "adaptive"
    AWS_MAX_ATTEMPTS             = 10
  }

  s3_existing_package = {
    bucket = var.custom_s3_bucket == "" ? "coralogix-serverless-repo-${data.aws_region.this.id}" : var.custom_s3_bucket
    key    = "${var.package_name}-generator.zip"
  }

  attach_policy_statements = true
  policy_statements = {
    ec2 = {
      effect = "Allow"
      actions = [
        "ec2:DescribeInstances"
      ]
      resources = ["*"]
    }
    lambda = {
      effect = "Allow"
      actions = [
        "lambda:ListVersionsByFunction",
        "lambda:GetFunctionConfiguration",
        "lambda:GetFunctionConcurrency",
        "lambda:ListTags",
        "lambda:ListAliases",
        "lambda:ListEventSourceMappings",
        "lambda:GetPolicy"
      ]
      resources = ["*"]
    }
    sqs = {
      effect = "Allow"
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [aws_sqs_queue.metadata_queue.arn]
    }
    assume_role = var.crossaccount_mode == "Disabled" ? null : {
      effect = "Allow"
      actions = [
        "sts:AssumeRole"
      ]
      resources = ["arn:aws:iam::*:role/${var.crossaccount_iam_role_name}"]
    }
    secrets = {
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
    SQS = {
      principal  = "sqs.amazonaws.com"
      source_arn = aws_sqs_queue.metadata_queue.arn
    }
  }

  create_current_version_allowed_triggers = true
  event_source_mapping = {
    sqs = {
      event_source_arn    = aws_sqs_queue.metadata_queue.arn
      batch_size          = 1
      maximum_concurrency = var.maximum_concurrency
    }
  }

  tags = merge(var.tags, local.tags)
}

resource "aws_sns_topic" "this" {
  name_prefix  = "${local.function_name}-Failure"
  display_name = "${local.function_name}-Failure"
  tags         = merge(var.tags, local.tags)
}

resource "aws_secretsmanager_secret" "api_key_secret" {
  count       = var.secret_manager_enabled && var.create_secret ? 1 : 0
  name        = "lambda/coralogix/${data.aws_region.this.id}/${local.function_name}"
  description = "Coralogix Send Your Data key Secret"
}

resource "aws_secretsmanager_secret_version" "service_user" {
  count         = var.secret_manager_enabled && var.create_secret ? 1 : 0
  depends_on    = [aws_secretsmanager_secret.api_key_secret]
  secret_id     = aws_secretsmanager_secret.api_key_secret[count.index].id
  secret_string = var.api_key
}

resource "aws_sns_topic_subscription" "this" {
  count     = var.notification_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_cloudwatch_event_rule" "cloudtrail" {
  count       = var.event_mode != "Disabled" ? 1 : 0
  name        = "${local.function_name}-cloudtrail-events"
  description = "Route CloudTrail events to resource metadata collector"
  event_pattern = jsonencode({
    "detail-type" : ["AWS API Call via CloudTrail"],
    "source" : ["aws.ec2", "aws.lambda"],
    "detail" : {
      "eventSource" : ["ec2.amazonaws.com", "lambda.amazonaws.com"],
      "eventName" : ["RunInstances", "CreateFunction20150331"],
      "errorCode" : [{
        "exists" : false
      }]
    }
  })
}

resource "aws_cloudwatch_event_target" "cloudtrail" {
  count     = var.event_mode != "Disabled" ? 1 : 0
  rule      = aws_cloudwatch_event_rule.cloudtrail[0].name
  target_id = "ResourceMetadataGenerator"
  arn       = aws_sqs_queue.metadata_queue.arn

  input_transformer {
    input_paths = {
      source = "$.source"
      detail = "$.detail"
    }
    input_template = <<EOF
{
  "source": <source>,
  "detail": <detail>
}
EOF
  }
}

resource "aws_sqs_queue_policy" "cloudtrail" {
  count     = var.event_mode != "Disabled" ? 1 : 0
  queue_url = aws_sqs_queue.metadata_queue.url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.metadata_queue.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" : aws_cloudwatch_event_rule.cloudtrail[0].arn
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket" "cloudtrail" {
  count         = var.event_mode == "EnabledCreateTrail" ? 1 : 0
  bucket        = lower("${local.function_name}-cloudtrail")
  force_destroy = false
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count                   = var.event_mode == "EnabledCreateTrail" ? 1 : 0
  bucket                  = aws_s3_bucket.cloudtrail[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.event_mode == "EnabledCreateTrail" ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail[0].arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "this" {
  count                         = var.event_mode == "EnabledCreateTrail" ? 1 : 0
  depends_on                    = [aws_s3_bucket_policy.cloudtrail]
  name                          = "${local.function_name}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}
