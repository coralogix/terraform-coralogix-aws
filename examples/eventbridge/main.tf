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

module "eventbridge_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/eventbridge"
  eventbridge_stream             = var.coralogix_eventbridge_stream_name
  sources                        = var.eventbridge_sources
  role_name                      = var.eventbridge_role_name
  private_key                    = var.coralogix_privatekey
  coralogix_region               = var.coralogix_region
}