terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.17.1"
    }
  }
}

locals {
  endpoint_url = {
    "us" = {
      url = "https://firehose-ingress.coralogix.us/firehose"
    }
    "singapore" = {
      url = "https://firehose-ingress.coralogixsg.com/firehose"
    }
    "ireland" = {
      url = "https://firehose-ingress.coralogix.com/firehose"
    }
    "india" = {
      url = "https://firehose-ingress.coralogix.in/firehose"
    }
    "stockholm" = {
      url = "https://firehose-ingress.eu2.coralogix.com/firehose"
    }
  }
  tags = merge(var.user_supplied_tags, {
    terraform-module         = "kinesis-firehose-to-coralogix"
    terraform-module-version = "v0.1.0"
    managed-by               = "coralogix-terraform"
  })
  application_name = var.application_name == null ? "coralogix-${var.firehose_stream}" : var.application_name
}

data "aws_caller_identity" "current_identity" {}
data "aws_region" "current_region" {}

################################################################################
# Firehose Delivery Stream
################################################################################

resource "aws_cloudwatch_log_group" "firehose_loggroup" {
  tags              = local.tags
  name              = "/aws/kinesisfirehose/${var.firehose_stream}"
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
  tags   = merge(local.tags, {Name="${var.firehose_stream}-backup"})
  bucket = "${var.firehose_stream}-backup"
}

resource "aws_s3_bucket_public_access_block" "firehose_bucket_bucket_access" {
  bucket = aws_s3_bucket.firehose_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

### IAM role for s3 configuration
resource "aws_iam_role" "firehose_to_coralogix" {
  tags               = local.tags
  name               = var.firehose_stream
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "firehose_to_http_metric_policy" {
  name   = "firehose_to_http_policy"
  role   = aws_iam_role.firehose_to_coralogix.id
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
                "${aws_s3_bucket.firehose_bucket.arn}",
                "${aws_s3_bucket.firehose_bucket.arn}/*"
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
                   "kms:EncryptionContext:aws:s3:arn": "${aws_s3_bucket.firehose_bucket.arn}/prefix*"
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
           "Resource": "arn:aws:kinesis:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:stream/${var.firehose_stream}"
        },
        {
           "Effect": "Allow",
           "Action": [
               "logs:PutLogEvents"
           ],
           "Resource": [
               "${aws_cloudwatch_log_group.firehose_loggroup.arn}"
           ]
        },
        {
          "Effect": "Allow",
          "Action": [
              "lambda:InvokeFunction",
              "lambda:GetFunctionConfiguration"
          ],
          "Resource": "${aws_lambda_function.lambda_processor.arn}:*"
        }
    ]
}
EOF
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_iam" {
  name               = "${var.firehose_stream}-transform-lambda-iam"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda_iam_policy" {
  name   = "${var.firehose_stream}-transform-lambda-iam"
  role   = aws_iam_role.lambda_iam.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Action": [
              "tag:GetResources",
              "ec2:DescribeTransitGateway*",
              "ec2:DescribeTags",
              "ec2:DescribeRegions",
              "ec2:DescribeInstances",
              "dms:DescribeReplicationTasks",
              "dms:DescribeReplicationInstances",
              "apigateway:GET"
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
  name              = "/aws/lambda/${aws_lambda_function.lambda_processor.function_name}"
  retention_in_days = var.cloudwatch_retention_days
  tags              = local.tags
}

resource "aws_lambda_function" "lambda_processor" {
  s3_bucket = "cx-cw-metrics-tags-lambda-processor-${data.aws_region.current_region.name}"
  s3_key = "function.zip"
  function_name = "${var.firehose_stream}-tags-processor"
  role          = aws_iam_role.lambda_iam.arn
  handler       = "function"
  runtime       = "go1.x"
  timeout       = "60"
  tags          = local.tags
}

resource "aws_kinesis_firehose_delivery_stream" "coralogix_stream" {
  tags        = local.tags
  name        = "coralogix-${var.firehose_stream}"
  destination = "http_endpoint"

  s3_configuration {
    role_arn           = aws_iam_role.firehose_to_coralogix.arn
    bucket_arn         = aws_s3_bucket.firehose_bucket.arn
    buffer_size        = 5
    buffer_interval    = 300
    compression_format = "GZIP"
  }

  http_endpoint_configuration {
    url                = var.coralogix_firehose_custom_endpoint != null ? var.coralogix_firehose_custom_endpoint : local.endpoint_url[var.coralogix_region].url
    name               = "Coralogix"
    access_key         = var.privatekey
    buffering_size     = 6
    buffering_interval = 60
    s3_backup_mode     = "FailedDataOnly"
    role_arn           = aws_iam_role.firehose_to_coralogix.arn
    retry_duration     = 30
    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.firehose_loggroup.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_logstream_dest.name
    }

    request_configuration {
      content_encoding = "GZIP"

      common_attributes {
        name  = "integrationType"
        value = var.integration_type
      }

      common_attributes {
        name  = "applicationName"
        value = local.application_name
      }
    }

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.lambda_processor.arn}:$LATEST"
        }

        parameters {
          parameter_name  = "BufferSizeInMBs"
          parameter_value = "1"
        }

        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "60"
        }
      }
    }
  }
}

################################################################################
# CloudWatch Metrics Stream
################################################################################

### IAM role for CloudWatch metric streams
resource "aws_iam_role" "metric_streams_to_firehose" {
  tags               = local.tags
  count              = var.enable_cloudwatch_metricstream == true ? 1 : 0
  name               = "${var.firehose_stream}_metric_streams_role"
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
  count  = var.enable_cloudwatch_metricstream == true ? 1 : 0
  name   = "metrics_streams_to_firehose_policy"
  role   = aws_iam_role.metric_streams_to_firehose[0].id
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
            "Resource": "${aws_kinesis_firehose_delivery_stream.coralogix_stream.arn}"
        }
    ]
}
EOF
}

# Creating one metric stream for all namespaces
resource "aws_cloudwatch_metric_stream" "cloudwatch_metric_stream_all_ns" {
  tags          = local.tags
  count         = var.include_all_namespaces && var.enable_cloudwatch_metricstream ? 1 : 0
  name          = "cloudwatch_metrics"
  role_arn      = aws_iam_role.metric_streams_to_firehose[0].arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.coralogix_stream.arn
  output_format = var.output_format
}

# Creating metric streams only for specific namespaces
resource "aws_cloudwatch_metric_stream" "cloudwatch_metric_stream_included_ns" {
  tags          = local.tags
  count         = !var.include_all_namespaces && var.enable_cloudwatch_metricstream ? 1 : 0
  name          = var.firehose_stream
  role_arn      = aws_iam_role.metric_streams_to_firehose[0].arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.coralogix_stream.arn
  output_format = var.output_format
  dynamic "include_filter" {
    for_each = var.include_metric_stream_namespaces
    content {
      namespace = "${include_filter.value}"
    }
  }
}
