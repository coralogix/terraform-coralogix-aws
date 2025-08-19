terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Random string for unique bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  lower   = true
  numeric = true
  upper   = false
  special = false
}

# S3 Bucket for OpenTelemetry Configuration
resource "aws_s3_bucket" "otel_config_bucket" {
  bucket = "coralogix-otel-config-tf-test-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "Coralogix OTEL Config Test Bucket"
    Environment = "test"
    Project     = "otel-testing"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "otel_config_bucket_versioning" {
  bucket = aws_s3_bucket.otel_config_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "otel_config_bucket_public_access_block" {
  bucket = aws_s3_bucket.otel_config_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Object for OpenTelemetry Configuration
resource "aws_s3_object" "otel_config" {
  bucket = aws_s3_bucket.otel_config_bucket.id
  key    = "configs/otel-config.yaml"
  source = "${path.module}/../../local_config.yaml"
  etag   = filemd5("${path.module}/../../local_config.yaml")

  tags = {
    Name        = "Coralogix OTEL Config"
    Environment = "test"
    Project     = "otel-testing"
  }
}

# ECS Task Execution Role for S3 Access
resource "aws_iam_role" "ecs_task_execution_role_s3" {
  name = "coralogix-otel-s3-tf-test-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the AWS managed policy for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_s3_policy" {
  role       = aws_iam_role.ecs_task_execution_role_s3.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for S3 access
resource "aws_iam_policy" "ecs_task_s3_policy" {
  name        = "coralogix-otel-s3-tf-test-policy"
  description = "Policy allowing access to S3 bucket for OpenTelemetry configuration"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.otel_config_bucket.arn}/*"
      }
    ]
  })
}

# Attach the S3 policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_s3_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role_s3.name
  policy_arn = aws_iam_policy.ecs_task_s3_policy.arn
}

# Outputs to reference in your tests
output "s3_config_bucket" {
  value = aws_s3_bucket.otel_config_bucket.bucket
}

output "s3_config_key" {
  value = aws_s3_object.otel_config.key
}

output "s3_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role_s3.arn
} 