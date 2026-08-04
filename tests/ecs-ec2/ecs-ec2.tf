terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ecs-ec2" {
  source                      = "../../modules/ecs-ec2"
  ecs_cluster_name            = var.ecs_cluster_name
  image                       = var.image
  image_version               = var.image_version
  supervisor_enabled          = var.supervisor_enabled
  supervised_image_repository = var.supervised_image_repository
  supervised_image_version    = var.supervised_image_version
  memory                      = var.memory

  coralogix_region = var.coralogix_region
  custom_domain    = var.custom_domain

  use_api_key_secret = var.use_api_key_secret
  api_key_secret_arn = var.api_key_secret_arn
  api_key            = var.api_key

  s3_config_bucket         = var.s3_config_bucket
  s3_config_key            = var.s3_config_key
  s3_supervisor_config_key = var.s3_supervisor_config_key
  initial_fallback_configs = var.initial_fallback_configs

  profiling_enabled                  = var.profiling_enabled
  profiling_s3_config_bucket         = var.profiling_s3_config_bucket
  profiling_s3_config_key            = var.profiling_s3_config_key
  profiling_initial_fallback_configs = var.profiling_initial_fallback_configs
  profiling_memory                   = var.profiling_memory

  task_execution_role_arn = var.task_execution_role_arn
  task_role_arn           = var.task_role_arn
  task_definition_arn     = var.task_definition_arn

  health_check_enabled  = var.health_check_enabled
  health_check_interval = var.health_check_interval
  health_check_timeout  = var.health_check_timeout
  health_check_retries  = var.health_check_retries

  tags = coalesce(var.tags, {
    Environment = "test"
    Project     = "otel-testing"
  })
}
