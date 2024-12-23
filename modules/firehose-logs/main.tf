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
  endpoint_url    = "https://ingress.${local.endpoint_domain}/aws/firehose"

  tags = var.override_default_tags == false ? merge(var.user_supplied_tags, {
    terraform-module         = "kinesis-firehose-to-coralogix"
    terraform-module-version = "v0.1.0"
    managed-by               = "coralogix-terraform"
    custom_endpoint          = local.endpoint_url
  }) : var.user_supplied_tags

  # global resource referecing
  s3_backup_bucket_arn  = var.existing_s3_backup != null ? one(data.aws_s3_bucket.exisiting_s3_bucket[*].arn) : one(aws_s3_bucket.new_s3_bucket[*].arn)
  firehose_iam_role_arn = var.existing_firehose_iam != null ? one(data.aws_iam_role.existing_firehose_iam[*].arn) : one(aws_iam_role.new_firehose_iam[*].arn)

  #new global resource namings
  new_s3_backup_bucket_name = var.s3_backup_custom_name != null ? var.s3_backup_custom_name : "${var.firehose_stream}-backup-logs"
  new_firehose_iam_name     = var.firehose_iam_custom_name != null ? var.firehose_iam_custom_name : "${var.firehose_stream}-firehose-logs-iam"

  arn_prefix = var.govcloud_deployment ? "arn:aws-us-gov" : "arn:aws"
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

data "aws_s3_bucket" "exisiting_s3_bucket" {
  count  = var.existing_s3_backup != null ? 1 : 0
  bucket = var.existing_s3_backup
}

resource "aws_s3_bucket" "new_s3_bucket" {
  count  = var.existing_s3_backup != null ? 0 : 1
  tags   = merge(local.tags, { Name = local.new_s3_backup_bucket_name })
  bucket = local.new_s3_backup_bucket_name
}

resource "aws_s3_bucket_public_access_block" "firehose_bucket_bucket_access" {
  count  = var.existing_s3_backup != null ? 0 : 1
  bucket = one(aws_s3_bucket.new_s3_bucket[*].id)

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
# Firehose Logs Stream
################################################################################

data "aws_iam_role" "existing_firehose_iam" {
  count = var.existing_firehose_iam != null ? 1 : 0
  name  = var.existing_firehose_iam
}

resource "aws_iam_role" "new_firehose_iam" {
  count = var.existing_firehose_iam != null ? 0 : 1
  tags  = local.tags
  name  = local.new_firehose_iam_name
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
    name = local.new_firehose_iam_name
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
            "${local.s3_backup_bucket_arn}",
            "${local.s3_backup_bucket_arn}/*"
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
          "Resource" = "${local.arn_prefix}:kinesis:${data.aws_region.current_region.name}:${data.aws_caller_identity.current_identity.account_id}:stream/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "${aws_cloudwatch_log_group.firehose_loggroup.arn}"
          ]
        }
      ]
    })
  }
}

# Add additional policies to the firehose IAM role
resource "aws_iam_role_policy_attachment" "policy_attachment_firehose" {
  count      = var.existing_firehose_iam != null ? 0 : 1
  role       = one(aws_iam_role.new_firehose_iam[*].name)
  policy_arn = "${local.arn_prefix}:iam::aws:policy/AmazonKinesisFirehoseFullAccess"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_kinesis" {
  count      = var.existing_firehose_iam != null ? 0 : 1
  role       = one(aws_iam_role.new_firehose_iam[*].name)
  policy_arn = "${local.arn_prefix}:iam::aws:policy/AmazonKinesisReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "policy_attachment_cloudwatch" {
  count      = var.existing_firehose_iam != null ? 0 : 1
  role       = one(aws_iam_role.new_firehose_iam[*].name)
  policy_arn = "${local.arn_prefix}:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_kinesis_firehose_delivery_stream" "coralogix_stream_logs" {
  tags        = merge(local.tags, { LogDeliveryEnabled = "true" })
  name        = var.firehose_stream
  destination = "http_endpoint"

  dynamic "kinesis_source_configuration" {
    for_each = var.source_type_logs == "KinesisStreamAsSource" && var.kinesis_stream_arn != null ? [1] : []
    content {
      kinesis_stream_arn = var.kinesis_stream_arn
      role_arn           = local.firehose_iam_role_arn
    }
  }

  http_endpoint_configuration {
    url                = local.endpoint_url
    name               = "Coralogix"
    access_key         = var.api_key
    buffering_size     = 6
    buffering_interval = 60
    s3_backup_mode     = "FailedDataOnly"
    role_arn           = local.firehose_iam_role_arn
    retry_duration     = 300

    s3_configuration {
      role_arn           = local.firehose_iam_role_arn
      bucket_arn         = local.s3_backup_bucket_arn
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
