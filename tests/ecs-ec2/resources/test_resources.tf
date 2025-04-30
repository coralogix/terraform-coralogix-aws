terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Parameter Store Parameter for OpenTelemetry Config
resource "aws_ssm_parameter" "otel_config" {
  name        = "cx_otel_config-tf-test"
  description = "Coralogix OpenTelemetry Collector Configuration"
  type        = "String"
  tier        = "Advanced"  # Advanced tier for larger parameter values
  value       = file("${path.module}/../local_config.yaml")
}

# Secrets Manager Secret for API Key
resource "aws_secretsmanager_secret" "api_key_secret" {
  name        = "cx_otel_api_key-tf-test"
  description = "Coralogix API Key for OpenTelemetry Collector"
  kms_key_id  = "alias/aws/secretsmanager"  # Default AWS managed key
}

resource "aws_secretsmanager_secret_version" "api_key_version" {
  secret_id     = aws_secretsmanager_secret.api_key_secret.id
  secret_string = var.api_key
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "coralogix-otel-tf-test-execution-role"
  
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
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom policy for Parameter Store and Secrets Manager access
resource "aws_iam_policy" "ecs_task_custom_policy" {
  name        = "coralogix-otel-tf-test-custom-policy"
  description = "Policy allowing access to Coralogix OpenTelemetry config parameter and API key secret"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = aws_ssm_parameter.otel_config.arn
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.api_key_secret.arn
      }
    ]
  })
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_custom_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_custom_policy.arn
}

# Outputs to reference in your tests
output "parameter_store_name" {
  value = aws_ssm_parameter.otel_config.name
}

output "api_key_secret_arn" {
  value = aws_secretsmanager_secret.api_key_secret.arn
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
