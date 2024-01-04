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

module "s3" {
  source = "./modules/coralogix-aws-shipper"

  coralogix_region = "EU1"
  api_key          = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
  integration_type = "CloudWatch"
  log_groups = ["gr-test"]
#   sns_topic_name = "gr-topic-integration"
#   sqs_name = "gr-test-sqs"
#   lambda_name = "gr-test-lambda2"
  store_api_key_in_secrets_manager = false
}