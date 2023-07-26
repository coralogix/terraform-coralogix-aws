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
  region = "eu-west-1"
}

module "resource-metadata" {
  source = "../../../modules/provisioning/s3-archive"

  coralogix_region = "eu-west-1"
}