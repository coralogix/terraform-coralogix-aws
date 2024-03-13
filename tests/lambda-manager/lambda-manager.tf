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

module "lambda-manager" {
  source = "../../modules/lambda-manager"

  regex_pattern = ".*"
  destination_arn = "arn:aws:lambda:us-east-1:12345678910:function:*"
  logs_filter = "custome-test"
  destination_type = "lambda"
}