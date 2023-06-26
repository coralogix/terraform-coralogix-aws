terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "kinesis" {
  source = "../../modules/kinesis"

  coralogix_region        = "Europe"
  private_key             = "{{ secrets.TESTING_PRIVATE_KEY }}"
  ssm_enable              = "false"
  application_name        = "kinesis"
  subsystem_name          = "logs"
  kinesis_stream_name     = "github-action-test-data-stream"
}  