terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.15.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

