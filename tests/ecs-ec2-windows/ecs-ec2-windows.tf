terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "api_key" {
  type        = string
  sensitive   = true
}

variable "ecs_cluster_name" {
  type        = string
}

variable "security_group_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list
}

variable "app_image" {
  type        = string
  default     = ""
}

module "ecs_ec2_windows_demo" {
  source            = "../../modules/ecs-ec2-windows"
  ecs_cluster_name  = var.ecs_cluster_name
  coralogix_region  = "Singapore"
  api_key           = var.api_key
  security_group_id = var.security_group_id
  subnet_ids        = var.subnet_ids
  app_image         = var.app_image
}
