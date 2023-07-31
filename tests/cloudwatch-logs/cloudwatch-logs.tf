terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cloudwatch" {
  source = "../../modules/cloudwatch-logs"

  coralogix_region = "Europe"
  private_key      = "{{ secrets.TESTING_PRIVATE_KEY }}"
  application_name = "cloudwatch-logs"
  subsystem_name   = "logs"
  log_groups       = ["github-action-testing-log-stream"]
}