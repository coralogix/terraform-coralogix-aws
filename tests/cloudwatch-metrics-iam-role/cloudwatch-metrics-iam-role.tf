terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "random_id" "this" {
  byte_length = 8
}

module "coralogix_role" {
  source = "../../modules/cloudwatch-metrics-iam-role"

  coralogix_company_id = "01234567890"
  coralogix_region     = "US2"

  role_name          = "coralogix-aws-metrics-integration-role"
  external_id_secret = random_id.this.id

}

output "coralogix_metrics_role_arn" {
  description = "The ARN of the Coralogix AWS Metrics role."
  value       = module.coralogix_role.coralogix_metrics_role_arn
}

output "external_id" {
  description = "The external ID used in sts:AssumeRole, computed as <external_id_secret>@<coralogix_company_id>."
  value       = module.coralogix_role.external_id
}
