terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  default_tags {
    tags = {
      service = "Coralogix"
    }
  }
}

variable "coralogix_company_id" {}
variable "coralogix_region" {}
variable "role_name" {}
variable "external_id_secret" {}

module "coralogix_role" {
  source = "../../modules/cloudwatch-metrics-iam-role"

  coralogix_company_id = var.coralogix_company_id
  coralogix_region     = var.coralogix_region

  role_name          = var.role_name
  external_id_secret = var.external_id_secret

}

output "coralogix_metrics_role_arn" {
  description = "The ARN of the Coralogix AWS Metrics role."
  value       = module.coralogix_role.coralogix_metrics_role_arn
}

output "external_id" {
  description = "The external ID used in sts:AssumeRole, computed as <external_id_secret>@<coralogix_company_id>."
  value       = module.coralogix_role.external_id
}
