# Creates IAM roles for an existing S3 bucket (for custom roles test)
# Usage: terraform apply -var="bucket_name=otel-config-dm"

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

variable "bucket_name" {
  description = "S3 bucket name the roles will have read access to"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  bucket_arn = "arn:aws:s3:::${var.bucket_name}"
}

resource "aws_iam_role" "execution_role" {
  name = "coralogix-otel-tf-test-execution-role-${replace(var.bucket_name, ".", "-")}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_ecs" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_s3" {
  name = "S3ReadAccess"
  role = aws_iam_role.execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:GetObjectVersion"]
      Resource = "${local.bucket_arn}/*"
    }]
  })
}

resource "aws_iam_role" "task_role" {
  name = "coralogix-otel-tf-test-task-role-${replace(var.bucket_name, ".", "-")}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "task_s3" {
  name = "S3ReadAccess"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:GetObjectVersion"]
      Resource = "${local.bucket_arn}/*"
    }]
  })
}

output "task_execution_role_arn" {
  value = aws_iam_role.execution_role.arn
}

output "task_role_arn" {
  value = aws_iam_role.task_role.arn
}
