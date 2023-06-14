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
  region = "us-west-1"
}

module "s3" {
  source = "../../modules/s3"

  coralogix_region   = "Europe"
  private_key        = "{{ secrets.TESTING_PRIVATE_KEY }}"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "github-action-testing-bucket"
  integration_type   = "s3"
}