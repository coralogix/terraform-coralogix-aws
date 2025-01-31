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
  region = "us-east-1"
}

module "resource-metadata-sqs" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region = "EU1"
  private_key      = "{{ secrets.TESTING_PRIVATE_KEY }}"
}
