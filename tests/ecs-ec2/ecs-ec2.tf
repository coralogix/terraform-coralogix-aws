terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-1"
}

variable "private_key" {
  description = "The Coralogix Send-Your-Data API key for your Coralogix account."
  type        = string
  sensitive   = true
}

module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "latest"
  memory                   = 256
  coralogix_region         = "Singapore"
  default_application_name = "ecs-ec2"
  private_key              = var.private_key
  metrics                  = true
}
