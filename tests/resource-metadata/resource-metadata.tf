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

module "resource-metadata" {
  source = "../../modules/resource-metadata"

  coralogix_region = "Europe"
  private_key      = "{{ secrets.TESTING_PRIVATE_KEY }}"
}