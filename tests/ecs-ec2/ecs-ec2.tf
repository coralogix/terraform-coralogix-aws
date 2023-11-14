terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = local.env.aws_region_name
}

variable "otel_config_file" {
  description = "[Optional] Path to a custom opentelemetry configuration file"
  type        = string
  default     = null
}

module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "latest"
  memory                   = 256
  coralogix_region         = local.env.coralogix_region
  coralogix_endpoint       = var.coralogix_endpoint
  default_application_name = "ecs-ec2"
  default_subsystem_name   = "collector"
  api_key                  = local.env.api_key
  otel_config_file         = var.otel_config_file
  metrics                  = true
}
