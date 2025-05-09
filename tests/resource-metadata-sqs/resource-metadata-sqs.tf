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

module "resource-metadata-sqs-multi-region" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region = "EU1"
  api_key          = "{{ secrets.TESTING_PRIVATE_KEY }}"
  source_regions   = ["eu-north-1", "eu-west-1", "us-east-1"]
}

module "resource-metadata-sqs-cross-account-config" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region               = "EU1"
  api_key                        = "{{ secrets.TESTING_PRIVATE_KEY }}"
  crossaccount_mode              = "Config"
  crossaccount_config_aggregator = "config-aggregator"
  crossaccount_iam_role_name     = "CrossAccountRole"
}

module "resource-metadata-sqs-cross-account-static-iam" {
  source = "../../modules/resource-metadata-sqs"

  coralogix_region           = "EU1"
  api_key                    = "{{ secrets.TESTING_PRIVATE_KEY }}"
  crossaccount_mode          = "StaticIAM"
  source_regions             = ["eu-north-1", "eu-west-1", "us-east-1"]
  crossaccount_account_ids   = ["123456789012", "123456789013"]
  crossaccount_iam_role_name = "CrossAccountRole"
}
