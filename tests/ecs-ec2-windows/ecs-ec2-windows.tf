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

# Use default VPC subnets and default security group so plan/validate can run without a pre-existing Windows cluster.
# For apply you need an existing Windows ECS cluster; override subnet_ids/security_group_ids via tfvars if needed.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

module "ecs-ec2-windows" {
  source = "../../modules/ecs-ec2-windows"

  ecs_cluster_name   = var.ecs_cluster_name
  subnet_ids         = length(var.subnet_ids) > 0 ? var.subnet_ids : data.aws_subnets.default.ids
  security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : [data.aws_security_group.default.id]

  image         = var.image
  image_version = var.image_version

  cpu    = var.cpu
  memory = var.memory

  coralogix_region = var.coralogix_region
  custom_domain    = var.custom_domain

  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name

  use_api_key_secret = var.use_api_key_secret
  api_key_secret_arn = var.api_key_secret_arn
  api_key            = var.api_key

  config_source                      = var.config_source
  s3_config_bucket                   = var.s3_config_bucket
  s3_config_key                      = var.s3_config_key
  custom_config_parameter_store_name = var.custom_config_parameter_store_name

  task_execution_role_arn = var.task_execution_role_arn
  task_role_arn           = var.task_role_arn

  service_discovery_registry_arn = var.service_discovery_registry_arn

  health_check_enabled = var.health_check_enabled

  tags = {
    Environment = "test"
    Project     = "otel-testing"
  }
}
