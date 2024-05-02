terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = " < 6.0 , >= 5.0 "
    }
  }
}

module "locals" {
  source = "../locals_variables"

  integration_type = "firehose-logs"
  random_string    = random_string.this.result
}

locals {
  endpoint_domain = var.custom_domain != null ? var.custom_domain : module.locals.coralogix_domains[var.coralogix_region]
  endpoint_url    = "https://firehose-ingress.${local.endpoint_domain}/firehose"

  tags = var.override_default_tags == false ? merge(var.user_supplied_tags, {
    terraform-module         = "kinesis-firehose-to-coralogix"
    terraform-module-version = "v0.1.0"
    managed-by               = "coralogix-terraform"
    custom_endpoint          = local.endpoint_url
  }) : var.user_supplied_tags

  # default namings
  cloud_watch_metric_stream_name = var.cloudwatch_metric_stream_custom_name != null ? var.cloudwatch_metric_stream_custom_name : var.firehose_stream
  s3_backup_bucket_name          = var.s3_backup_custom_name != null ? var.s3_backup_custom_name : var.s3_existing_backup_bucket != null ? var.s3_existing_backup_bucket : "${var.firehose_stream}-backup-metrics"
  lambda_processor_name          = var.lambda_processor_custom_name != null ? var.lambda_processor_custom_name : "${var.firehose_stream}-metrics-transform"
}

data "aws_caller_identity" "current_identity" {}
data "aws_region" "current_region" {}

data "aws_s3_bucket" "s3_bucket" {
  depends_on = [ aws_s3_bucket.firehose_bucket ]
  bucket     = var.s3_existing_backup_bucket != null ? var.s3_existing_backup_bucket : aws_s3_bucket.firehose_bucket.id
}

resource "random_string" "this" {
  length  = 6
  special = false
}

################################################################################
# Firehose Delivery Stream
################################################################################

resource "aws_cloudwatch_log_group" "firehose_loggroup" {
  tags              = local.tags
  name              = "/aws/kinesisfirehosemetrics/${var.firehose_stream}"
  retention_in_days = var.cloudwatch_retention_days
}

resource "aws_cloudwatch_log_stream" "firehose_logstream_dest" {
  name           = "DestinationDelivery"
  log_group_name = aws_cloudwatch_log_group.firehose_loggroup.name
}

resource "aws_cloudwatch_log_stream" "firehose_logstream_backup" {
  name           = "BackupDelivery"
  log_group_name = aws_cloudwatch_log_group.firehose_loggroup.name
}

resource "aws_s3_bucket" "firehose_bucket" {
  count = var.s3_existing_backup_bucket != null ? 0 : 1
  tags   = merge(local.tags, { Name = local.s3_backup_bucket_name })
  bucket = local.s3_backup_bucket_name
}

resource "aws_s3_bucket_public_access_block" "firehose_bucket_bucket_access" {
  bucket = data.aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "firehose_to_coralogix" {
  tags = local.tags
  name = "${var.firehose_stream}-firehose-metrics"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
        "Action" = "sts:AssumeRole",
        "Principal" = {
          "Service" = "firehose.amazonaws.com"
        },
        "Effect" = "Allow"
      }
    ]
  })
  inline_policy {
    name = "${var.firehose_stream}-firehose"
    policy = jsonencode({
      "Version" = "2012-10-17",
      "Statement" = [
        {
          "Effect" = "Allow",
          "Action" = [
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:PutObject"
          ],
          "Resource" = [
            data.aws_s3_bucket.s3_bucket.arn,
            "${data.aws_s3_bucket.s3_bucket.arn}/*"
          ]
        },
        {
          "Effect" = "Allow",
          "Action" = [
            "kinesis:DescribeStream",
            "kinesis:GetShardIterator",
            "kinesis:GetRecords",
            "kinesis:ListShards"
          ],
          "Resource" = "arn:aws:kinesis:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:stream/*"
        },
        {
          "Effect" = "Allow",
          "Action" = [
            "*"
          ],
          "Resource" = [
            aws_cloudwatch_log_group.firehose_loggroup.arn
          ]
        }
      ]
    })
  }
}

################################################################################
# Firehose Metrics Stream
################################################################################

resource "aws_iam_policy" "firehose_to_coralogix_metric_policy" {
  name   = "${var.firehose_stream}-metrics-policy"
  tags   = local.tags
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
    [
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${data.aws_s3_bucket.s3_bucket.arn}",
                "${data.aws_s3_bucket.s3_bucket.arn}/*"
            ]
        },
        {
           "Effect": "Allow",
           "Action": [
               "kms:Decrypt",
               "kms:GenerateDataKey"
           ],
           "Resource": [
               "arn:aws:kms:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:key/key-id"
           ],
           "Condition": {
               "StringEquals": {
                   "kms:ViaService": "s3.${data.aws_region.current_region.name}.amazonaws.com"
               },
               "StringLike": {
                   "kms:EncryptionContext:aws:s3:arn": "${data.aws_s3_bucket.s3_bucket.arn}/prefix*"
               }
           }
        },
        {
           "Effect": "Allow",
           "Action": [
               "kinesis:DescribeStream",
               "kinesis:GetShardIterator",
               "kinesis:GetRecords",
               "kinesis:ListShards"
           ],
           "Resource": "arn:aws:kinesis:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:stream/*"
        },
        {
           "Effect": "Allow",
           "Action": [
               "logs:PutLogEvents"
           ],
           "Resource": [
               "${aws_cloudwatch_log_group.firehose_loggroup.arn}"
           ]
        }
        %{if var.lambda_processor_enable},
        {
          "Effect": "Allow",
          "Action": [
              "lambda:InvokeFunction",
              "lambda:GetFunctionConfiguration"
          ],
          "Resource": "${aws_lambda_function.lambda_processor[0].arn}:*"
        }
        %{else}
        %{endif}
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_to_coralogix_metric_policy" {
  policy_arn = aws_iam_policy.firehose_to_coralogix_metric_policy.arn
  role       = aws_iam_role.firehose_to_coralogix.name
}

data "aws_iam_policy_document" "lambda_assume_role" {
  count = var.lambda_processor_enable == true ? 1 : 0
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam_role" {
  count              = var.lambda_processor_enable == true ? 1 : 0
  name               = "${local.lambda_processor_name}-lambda"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role[count.index].json
}

resource "aws_iam_role_policy" "lambda_iam_policy" {
  count  = var.lambda_processor_enable == true ? 1 : 0
  name   = "${local.lambda_processor_name}-lambda"
  role   = aws_iam_role.lambda_iam_role[count.index].id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
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
              "storagegateway:ListGateways",
              "storagegateway:ListTagsForResource"
          ],
          "Effect": "Allow",
          "Resource": "*",
          "Sid": ""
      },
      {
          "Action": [
              "logs:PutLogEvents",
              "logs:CreateLogStream",
              "logs:CreateLogGroup"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:logs:*:*:*",
          "Sid": ""
      }
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "loggroup" {
  count             = var.lambda_processor_enable == true ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.lambda_processor[count.index].function_name}"
  retention_in_days = var.cloudwatch_retention_days
  tags              = local.tags
}

resource "aws_lambda_function" "lambda_processor" {
  count         = var.lambda_processor_enable ? 1 : 0
  s3_bucket     = "cx-cw-metrics-tags-lambda-processor-${data.aws_region.current_region.name}"
  s3_key        = "bootstrap.zip"
  function_name = local.lambda_processor_name
  role          = aws_iam_role.lambda_iam_role[count.index].arn
  handler       = "bootstrap"
  runtime       = "provided.al2"
  timeout       = "60"
  memory_size   = 512
  architectures = ["arm64"]
  tags          = local.tags

  environment {
    variables = {
      FILE_CACHE_PATH = "/tmp"
    }
  }
}

resource "aws_kinesis_firehose_delivery_stream" "coralogix_stream_metrics" {
  tags        = local.tags
  name        = "${var.firehose_stream}-metrics"
  destination = "http_endpoint"

  http_endpoint_configuration {
    url                = local.endpoint_url
    name               = "Coralogix"
    access_key         = var.private_key
    buffering_size     = 1
    buffering_interval = 60
    s3_backup_mode     = "FailedDataOnly"
    role_arn           = aws_iam_role.firehose_to_coralogix.arn
    retry_duration     = 30

    s3_configuration {
      role_arn           = aws_iam_role.firehose_to_coralogix.arn
      bucket_arn         = data.aws_s3_bucket.s3_bucket.arn
      buffering_size     = 5
      buffering_interval = 300
      compression_format = "GZIP"
    }

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.firehose_loggroup.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_logstream_dest.name
    }

    request_configuration {
      content_encoding = "GZIP"

      dynamic "common_attributes" {
        for_each = var.integration_type_metrics == null ? [] : [1]
        content {
          name  = "integrationType"
          value = var.integration_type_metrics
        }
      }

      dynamic "common_attributes" {
        for_each = var.application_name == null ? [] : [1]
        content {
          name  = "applicationName"
          value = var.application_name
        }
      }

      dynamic "common_attributes" {
        for_each = var.subsystem_name == null ? [] : [1]
        content {
          name  = "subsystemName"
          value = var.subsystem_name
        }
      }
    }

    dynamic "processing_configuration" {
      for_each = var.lambda_processor_enable == true ? [1] : []
      content {
        enabled = "true"

        processors {
          type = "Lambda"

          parameters {
            parameter_name  = "LambdaArn"
            parameter_value = "${aws_lambda_function.lambda_processor[0].arn}:$LATEST"
          }

          parameters {
            parameter_name  = "BufferSizeInMBs"
            parameter_value = "0.2"
          }

          parameters {
            parameter_name  = "BufferIntervalInSeconds"
            parameter_value = "61"
          }
        }
      }

    }
  }
}

################################################################################
# CloudWatch Metrics Stream
################################################################################

resource "aws_iam_role" "metric_streams_to_firehose_role" {
  tags               = local.tags
  count              = var.enable_cloudwatch_metricstream ? 1 : 0
  name               = "${local.cloud_watch_metric_stream_name}-cw"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "streams.metrics.cloudwatch.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "metric_streams_to_firehose_policy" {
  count  = var.enable_cloudwatch_metricstream ? 1 : 0
  name   = "${local.cloud_watch_metric_stream_name}-cw"
  role   = aws_iam_role.metric_streams_to_firehose_role[count.index].id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:DeleteDeliveryStream",
                "firehose:PutRecord",
                "firehose:PutRecordBatch",
                "firehose:UpdateDestination"
            ],
            "Resource": "${aws_kinesis_firehose_delivery_stream.coralogix_stream_metrics.arn}"
        }
    ]
}
EOF
}

resource "aws_cloudwatch_metric_stream" "cloudwatch_metric_stream" {
  tags          = local.tags
  count         = var.enable_cloudwatch_metricstream ? 1 : 0
  name          = local.cloud_watch_metric_stream_name
  role_arn      = aws_iam_role.metric_streams_to_firehose_role[count.index].arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.coralogix_stream_metrics.arn
  output_format = var.output_format

  dynamic "include_filter" {
    for_each = var.include_metric_stream_namespaces
    content {
      namespace = include_filter.value
    }
  }
  dynamic "include_filter" {
    for_each = var.include_metric_stream_filter
    content {
      namespace    = include_filter.value.namespace
      metric_names = include_filter.value.metric_names
    }
  }

  dynamic "statistics_configuration" {
    for_each = var.additional_metric_statistics_enable == true ? var.additional_metric_statistics : []
    content {
      additional_statistics = statistics_configuration.value.additional_statistics
      include_metric {
        metric_name = statistics_configuration.value.metric_name
        namespace   = statistics_configuration.value.namespace
      }
    }
  }
}
