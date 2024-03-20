terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "coralogix-shipper-s3" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3"
  api_key            = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "gr-integrations-aws-testing"
  s3_key_prefix = "files"
  s3_key_suffix = ".txt"
}

module "coralogix-shipper-multiple-s3-integrations" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  api_key            = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
  s3_bucket_name     = "gr-integrations-aws-testing"
  integration_info = {
    "CloudTrail_integration" = {
      integration_type = "CloudTrail"
      application_name = "CloudTrail_application"
      subsystem_name   = "logs_from_cloudtrail"
    }
    "VpcFlow_integration" = {
      integration_type = "VpcFlow"
      application_name = "VpcFlow_application"
      subsystem_name   = "logs_from_vpcflow"
    }
    "S3_integration" = {
      integration_type = "S3"
      application_name = "s3_application"
      subsystem_name   = "s3_vpcflow"
      s3_key_prefix = "files"
    }
  }
}