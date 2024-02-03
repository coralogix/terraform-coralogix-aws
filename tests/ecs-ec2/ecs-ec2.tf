terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = var.ecs_cluster_name
  image_version            = "latest"
  memory                   = 256
  coralogix_region         = var.coralogix_region
  custom_domain            = var.custom_domain
  default_application_name = "ecs-ec2"
  default_subsystem_name   = "collector"
  api_key                  = var.api_key
  otel_config_file         = var.otel_config_file
  metrics                  = var.metrics
}
