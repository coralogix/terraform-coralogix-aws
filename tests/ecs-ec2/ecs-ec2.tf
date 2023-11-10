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
#  region = "ap-southeast-1"
}

variable "private_key" {
  description = "The Coralogix Send-Your-Data API key for your Coralogix account."
  type        = string
  sensitive   = true
}

# To test custom config file "$(pwd)/otel_config_custom.tftpl.yaml"
# Run  ```terraform plan -var otel_config_file="$(pwd)/otel_config_custom.tftpl.yaml"```
# This config file sets all logs severity to WARNING. Verify in your Coralogix account.
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
  coralogix_region         = "Singapore" # TODO set dynamically from region?
  default_application_name = "ecs-ec2"
  default_subsystem_name   = "default"
  private_key              = var.private_key
  otel_config_file         = var.otel_config_file
  metrics                  = true
}
