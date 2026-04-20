terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
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

module "s3-sqs-external-policy" {
  source = "../../modules/coralogix-aws-shipper"

  coralogix_region        = "EU1"
  api_key                 = "{{ secrets.TESTING_PRIVATE_KEY }}"
  application_name        = "s3-sqs"
  subsystem_name          = "logs"
  s3_bucket_name          = "github-action-bucket-testing"
  sqs_name                = "github-action-sqs-testing"
  integration_type        = "S3"
  create_sqs_queue_policy = false
  s3_notification         = false
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

module "metrics" {
  source = "../../modules/coralogix-aws-shipper"

  coralogix_region       = "EU1"
  api_key                = "{{ secrets.TESTING_PRIVATE_KEY }}"
  application_name       = "metrics"
  subsystem_name         = "metrics"
  s3_bucket_name         = "github-action-bucket-testing"
  telemetry_mode         = "metrics"
  batch_metrics          = true
  metrics_batch_max_size = 2
}
