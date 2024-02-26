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

module "lambda-manager" {
  source = "../../lambda-manager"

  regex_pattern = ".*"
  destination_arn = "arn:aws:lambda:us-east-1:12345678910:function:*"
  logs_filter = "custome-test"
  destination_role = "arn:aws:iam::12345678910:role/role_name"
  destination_type = "lambda"
}