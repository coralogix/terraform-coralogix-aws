terraform {
  # Set the backend here
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.17.1"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      terraform-module         = "kinesis-firehose-to-coralogix"
      terraform-module-version = "v0.0.1"
      managed-by               = "coralogix-terraform"
    }
  }
}

module "cloudwatch_firehose_coralogix" {
  source           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  for_each         = toset(var.coralogix_streams)
  firehose_stream  = each.key
  private_key      = var.private_key
  coralogix_region = var.coralogix_region
}
