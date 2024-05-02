terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "cloudwatch_firehose_logs_coralogix" {
  source                         = "coralogix/aws/coralogix//modules/firehose-logs"
  firehose_stream                = var.coralogix_firehose_stream_name
  private_key                    = ""
  coralogix_region               = "Europe"
  integration_type_logs          = "RawText"
  source_type_logs               = "DirectPut"
}