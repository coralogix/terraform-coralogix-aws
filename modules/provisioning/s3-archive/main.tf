locals {
  is_logs_bucket_name_empty    = var.logs_bucket_name != ""
  is_metrics_bucket_name_empty = var.metrics_bucket_name != ""
  is_same_bucket_name          = var.logs_bucket_name == var.metrics_bucket_name
  is_valid_region              = data.aws_region.current.name == var.aws_region
  coralogix_role_region        = lookup(var.aws_role_region, var.aws_region)

  logs_validations       = local.is_logs_bucket_name_empty && !local.is_same_bucket_name && (local.is_valid_region || var.bypass_valid_region != "")
  metrics_validations    = local.is_metrics_bucket_name_empty && !local.is_same_bucket_name && (local.is_valid_region || var.bypass_valid_region != "")
  kms_logs_validation    = local.logs_validations && var.logs_kms_arn != "" && contains(split(":", var.logs_kms_arn), var.aws_region)
  kms_metrics_validation = local.metrics_validations && var.metrics_kms_arn != "" && contains(split(":", var.metrics_kms_arn), var.aws_region)
  coralogix_log_role_arn = var.custom_coralogix_arn != "" ? "arn:aws:iam::${var.custom_coralogix_arn}:role/coralogix-archive-${local.coralogix_role_region}" : var.bypass_valid_region != "" ? "arn:aws:iam::${var.coralogix_arn_mapping[""]}:role/coralogix-archive-${local.coralogix_role_region}" : "arn:aws:iam::${var.coralogix_arn_mapping[var.aws_region]}:role/coralogix-archive-${local.coralogix_role_region}"
  coralogix_metrics_role_arn = var.custom_coralogix_arn != "" ? "arn:aws:iam::${var.custom_coralogix_arn}:root" : var.bypass_valid_region != "" ? "arn:aws:iam::${var.coralogix_arn_mapping[""]}:root" : "arn:aws:iam::${var.coralogix_arn_mapping[var.aws_region]}:root"
}

data "aws_region" "current" {}

resource "aws_s3_bucket" "logs_bucket_name" {
  count  = local.logs_validations ? 1 : 0
  bucket = var.logs_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket" "metrics_bucket_name" {
  count  = local.metrics_validations ? 1 : 0
  bucket = var.metrics_bucket_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  count  = local.logs_validations ? 1 : 0
  bucket = aws_s3_bucket.logs_bucket_name[count.index].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.coralogix_log_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging"
        ]
        Resource = [
          aws_s3_bucket.logs_bucket_name[count.index].arn,
          "${aws_s3_bucket.logs_bucket_name[count.index].arn}/*",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs_encryption" {
  count  = local.kms_logs_validation ? 1 : 0
  bucket = aws_s3_bucket.logs_bucket_name[count.index].bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.logs_kms_arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "metrics_bucket_policy" {
  count  = local.metrics_validations ? 1 : 0
  bucket = aws_s3_bucket.metrics_bucket_name[count.index].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = local.coralogix_metrics_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging"
        ]
        Resource = [
          aws_s3_bucket.metrics_bucket_name[count.index].arn,
          "${aws_s3_bucket.metrics_bucket_name[count.index].arn}/*",
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "metrics_encryption" {
  count  = local.kms_metrics_validation ? 1 : 0
  bucket = aws_s3_bucket.metrics_bucket_name[count.index].bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.metrics_kms_arn
    }
    bucket_key_enabled = true
  }
}


