# firehose access role to S3 lambda and cloudwatch
resource "aws_iam_role_policy" "s3_firehose_metrics_policy" {
  count = var.telemetry_mode == "metrics" ? 1 : 0
  name  = "s3_firehose_metrics_policy"
  role  = aws_iam_role.s3_firehose_metrics_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:AbortMultipartUpload", "s3:GetBucketLocation", "s3:GetObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:PutObject"]
        Resource = flatten([for bucket in local.s3_bucket_names : ["${local.arn_prefix}:s3:::${bucket}", "${local.arn_prefix}:s3:::${bucket}/*"]])
      },
      {
        Effect   = "Allow"
        Action   = ["logs:PutLogEvents", "logs:CreateLogStream"]
        Resource = ["${local.arn_prefix}:logs:${data.aws_region.this.name}:${data.aws_caller_identity.this.account_id}:log-group:${aws_cloudwatch_log_group.firehose_log_group[0].name}:*"]
      },
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction", "lambda:GetFunctionConfiguration"]
        Resource = var.lambda_name != null ? ["${local.arn_prefix}:lambda:*:*:${var.lambda_name}:$LATEST"] : ["${local.arn_prefix}:lambda:*:*:${module.locals.integration.function_name}:$LATEST"]
      },
    ]
  })
}

resource "aws_iam_role" "s3_firehose_metrics_role" {
  count = var.telemetry_mode == "metrics" ? 1 : 0

  name = "s3_firehose_metrics_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}

# firehose failed messages destination log group
resource "aws_cloudwatch_log_group" "firehose_log_group" {
  count = var.telemetry_mode == "metrics" ? 1 : 0

  name = "firehose_log_group"

  tags = {
    Environment = "production"
    Application = "firehose"
  }
}

resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  count = var.telemetry_mode == "metrics" ? 1 : 0

  name           = "firehose_log_stream"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group[0].name
}

# cloudwatch metrics log group access role to firehose
resource "aws_iam_role_policy" "cloudwatch_metrics_policy" {
  count = var.telemetry_mode == "metrics" ? 1 : 0
  name  = "firehose_access_policy_${random_string.lambda_role[0].result}"
  role  = aws_iam_role.cloudwatch_metrics_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["firehose:PutRecord", "firehose:PutRecordBatch"]
        Resource = ["${aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].arn}"]
      },
    ]
  })
}

# cloudwatch metrics stream
resource "aws_cloudwatch_metric_stream" "cloudWatch_metric_stream" {
  count         = var.telemetry_mode == "metrics" ? 1 : 0
  name          = "metrics-firehose-shipper-test-coralogix-metric-stream-${random_string.lambda_role[0].result}"
  role_arn      = aws_iam_role.cloudwatch_metrics_role[0].arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.extended_s3_stream[0].arn
  output_format = "opentelemetry1.0"

  dynamic "include_filter" {
    for_each = var.include_metric_stream_filter
    content {
      namespace    = include_filter.value.namespace
      metric_names = include_filter.value.metric_names
    }
  }
}

resource "aws_iam_role" "cloudwatch_metrics_role" {
  count = var.telemetry_mode == "metrics" ? 1 : 0

  name = "metrics-firehose-shipper-test-FirehoseAccessRole-${random_string.lambda_role[0].result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "streams.metrics.cloudwatch.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_kinesis_firehose_delivery_stream" "extended_s3_stream" {
  count       = var.telemetry_mode == "metrics" ? 1 : 0
  name        = "terraform-kinesis-firehose-extended-s3-test-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    s3_backup_mode     = "Enabled"
    role_arn           = aws_iam_role.s3_firehose_metrics_role[0].arn
    bucket_arn         = data.aws_s3_bucket.this[0].arn
    compression_format = "GZIP"
    prefix             = "coralogix-aws-shipper-metrics"
    buffering_size     = 5
    buffering_interval = 60

    s3_backup_configuration {
      bucket_arn         = data.aws_s3_bucket.this[0].arn
      role_arn           = aws_iam_role.s3_firehose_metrics_role[0].arn
      buffering_size     = 5
      buffering_interval = 60
      compression_format = "GZIP"
      prefix             = "coralogix-aws-shipper-metrics-backup"
    }
    processing_configuration {
      enabled = "true"
      processors {
        type = "Lambda"
        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${module.lambda.integration.lambda_function_arn}:$LATEST"
        }
        parameters {
          parameter_value = aws_iam_role.s3_firehose_metrics_role[0].arn
          parameter_name  = "RoleArn"
        }
      }
    }
    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group[0].name
      log_stream_name = aws_cloudwatch_log_stream.firehose_log_stream[0].name
    }
  }
}