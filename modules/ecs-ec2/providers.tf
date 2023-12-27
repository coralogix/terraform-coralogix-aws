terraform {
  required_version = ">= 0.13.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.24.0"
    }

    cloudflare = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}
