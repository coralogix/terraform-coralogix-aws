terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
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
  privatekey       = var.coralogix_privatekey
  coralogix_region = var.coralogix_region
}
