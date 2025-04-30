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

module "resource-metadata-sqs-no-event-mode" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region = "EU1"
  api_key          = "{{ secrets.TESTING_PRIVATE_KEY }}"
}

module "resource-metadata-sqs-event-mode" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region = "EU1"
  api_key          = "{{ secrets.TESTING_PRIVATE_KEY }}"
  event_mode       = "EnabledCreateTrail"
}

module "resource-metadata-sqs-event-mode-existing-trail" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region = "EU1"
  api_key          = "{{ secrets.TESTING_PRIVATE_KEY }}"
  event_mode       = "EnabledWithExistingTrail"
}

module "resource-metadata-sqs-multi-region-cross-account" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region            = "EU1"
  api_key                     = "{{ secrets.TESTING_PRIVATE_KEY }}"
  source_regions              = ["eu-north-1", "eu-west-1", "us-east-1"]
  cross_account_iam_role_arns = ["arn:aws:iam::123456789012:role/CrossAccountRole"]
}
