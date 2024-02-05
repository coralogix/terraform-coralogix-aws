terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "latest"
  memory                   = 256
  coralogix_region         = "Europe"
  custom_domain            = null
  default_application_name = "ecs-ec2"
  default_subsystem_name   = "collector"
  api_key                  = "1234567890_DUMMY_API_KEY"
  otel_config_file         = "./otel_config.tftpl.yaml"
  metrics                  = true
}
