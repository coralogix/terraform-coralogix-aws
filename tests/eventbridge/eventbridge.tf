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
  region = "us-west-1"
}

module "eventbridge" {
  source = "../../modules/eventbridge"

  eventbridge_stream             = "eventbridge_stream_test"
  sources                        = ["aws.autoscaling"]
  role_name                      = "eventbridge_role_name"
  private_key                    = "{{ secrets.TESTING_PRIVATE_KEY }}"
  coralogix_region               = "ireland"
}