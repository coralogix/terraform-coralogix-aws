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

module "ecs-ec2" {
  source           = "../../modules/ecs-ec2"
  ecs_cluster_name = var.ecs_cluster_name

  image         = var.image
  image_version = var.image_version

  memory = 256

  coralogix_region = var.coralogix_region
  custom_domain    = var.custom_domain

  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name

  use_api_key_secret = var.use_api_key_secret
  api_key_secret_arn = var.api_key_secret_arn
  api_key            = var.api_key

  # Configuration source and related variables
  config_source                      = var.config_source
  s3_config_bucket                   = var.s3_config_bucket
  s3_config_key                      = var.s3_config_key
  custom_config_parameter_store_name = var.custom_config_parameter_store_name
  otel_config_file                   = var.otel_config_file

  task_execution_role_arn = var.task_execution_role_arn

  tags = {
    Environment = "test"
    Project     = "otel-testing"
  }
}
