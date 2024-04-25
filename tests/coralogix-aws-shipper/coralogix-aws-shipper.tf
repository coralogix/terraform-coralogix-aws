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

module "s3" {
  source = "../../modules/coralogix-aws-shipper"

  coralogix_region = "EU1"
  api_key          = "{{ secrets.TESTING_PRIVATE_KEY }}"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "github-action-bucket-testing"
  integration_type = "S3"
}
module "cloudwatch" {
  source = "../../modules/coralogix-aws-shipper"

  coralogix_region = "EU1"
  api_key          = "{{ secrets.TESTING_PRIVATE_KEY }}"
  application_name = "cloudwatch-logs"
  subsystem_name   = "logs"
  log_groups       = ["github-action-testing-log-stream"]
  integration_type = "CloudWatch"
}