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

module "firehose" {
  source = "../../modules/firehose"

  coralogix_region = "ireland"
  private_key      = "{{ secrets.TESTING_PRIVATE_KEY }}"
  firehose_stream  = "test-stream"
}
