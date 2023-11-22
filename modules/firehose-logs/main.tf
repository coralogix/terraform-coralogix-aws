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
  s3_logs_backup_bucket_name = var.s3_backup_custom_name != null ? var.s3_backup_custom_name : "${var.firehose_stream}-backup-logs"
}

data "aws_caller_identity" "current_identity" {}
data "aws_region" "current_region" {}

resource "random_string" "this" {
  length  = 6
  special = false
}

################################################################################
# Firehose Delivery Stream
################################################################################

resource "aws_cloudwatch_log_group" "firehose_loggroup" {
  tags              = local.tags
  name              = "/aws/kinesisfirehoselogs/${var.firehose_stream}"
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
  tags   = merge(local.tags, { Name = local.s3_logs_backup_bucket_name })
  bucket = local.s3_logs_backup_bucket_name
}

resource "aws_s3_bucket_public_access_block" "firehose_bucket_bucket_access" {
  bucket = aws_s3_bucket.firehose_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "firehose_to_coralogix" {
  tags = local.tags
  name = "${var.firehose_stream}-firehose-logs"
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
            aws_s3_bucket.firehose_bucket.arn,
            "${aws_s3_bucket.firehose_bucket.arn}/*"
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
# Firehose Logs Stream
################################################################################

resource "aws_kinesis_firehose_delivery_stream" "coralogix_stream_logs" {
  tags        = local.tags
  name        = "${var.firehose_stream}-logs"
  destination = "http_endpoint"

  dynamic "kinesis_source_configuration" {
    for_each = var.source_type_logs == "KinesisStreamAsSource" && var.kinesis_stream_arn != null ? [1] : []
    content {
      kinesis_stream_arn = var.kinesis_stream_arn
      role_arn           = aws_iam_role.firehose_to_coralogix.arn
    }
  }

  http_endpoint_configuration {
    url                = local.endpoint_url
    name               = "Coralogix"
    access_key         = var.private_key
    buffering_size     = 6
    buffering_interval = 60
    s3_backup_mode     = "FailedDataOnly"
    role_arn           = aws_iam_role.firehose_to_coralogix.arn
    retry_duration     = 300

    s3_configuration {
      role_arn           = aws_iam_role.firehose_to_coralogix.arn
      bucket_arn         = aws_s3_bucket.firehose_bucket.arn
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
        for_each = var.integration_type_logs == null ? [] : [1]
        content {
          name  = "integrationType"
          value = var.integration_type_logs
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
  }
}

resource "aws_iam_role_policy_attachment" "example_policy_attachment" {
  role       = aws_iam_role.firehose_to_coralogix.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_role_policy_attachment" "additional_policy_attachment_1" {
  role       = aws_iam_role.firehose_to_coralogix.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "additional_policy_attachment_2" {
  role       = aws_iam_role.firehose_to_coralogix.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
