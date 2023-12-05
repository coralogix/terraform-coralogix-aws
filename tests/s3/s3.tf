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
module "s3" {
  source = "../../modules/s3"

  coralogix_region = "Europe"
  private_key      = "{{ secrets.TESTING_PRIVATE_KEY }}"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "github-action-bucket-testing"
  integration_type = "s3"
}