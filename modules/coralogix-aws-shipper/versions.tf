terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.32.0"
      configuration_aliases = [aws.bucket_s3]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}

