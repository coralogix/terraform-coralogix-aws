# uses terraform workspace name to determine AWS region
variable "api_keys" {
  type    = map(string)
  default = {}
}

variable "coralogix_endpoint" {
  type    = string
  default = null
}

locals {
  envs = {
    "default" : local.sg,
    "sg" : local.sg,
    "in" : local.in,
    "us" : local.us,
    "us2" : local.us2,
    "eu" : local.eu,
    "eu2" : local.eu2
  }
  sg = {
    aws_region_name  = "ap-southeast-1"
    coralogix_region = "Singapore"
    endpoint         = null
    api_key          = try(var.api_keys.sg, "UNDEFINED")
  }
  us = {
    aws_region_name  = "us-east-2"
    coralogix_region = "US"
    endpoint         = null
    api_key          = try(var.api_keys.us, "UNDEFINED")
  }
  in = {
    aws_region_name  = "ap-south-1"
    coralogix_region = "India"
    endpoint         = null
    api_key          = try(var.api_keys.in, "UNDEFINED")
  }
  us2 = {
    aws_region_name  = "us-west-2"
    coralogix_region = "US2"
    endpoint         = null
    api_key          = try(var.api_keys.us2, "UNDEFINED")
  }
  eu = {
    aws_region_name  = "eu-west-1"
    coralogix_region = "EU"
    endpoint         = null
    api_key          = try(var.api_keys.eu, "UNDEFINED")
  }
  eu2 = {
    aws_region_name  = "eu-north-1"
    coralogix_region = "EU2"
    endpoint         = null
    api_key          = try(var.api_keys.eu2, "UNDEFINED")
  }
  env_name = contains(keys(local.envs), terraform.workspace) ? terraform.workspace : "default"
  env      = merge(local.envs.default, local.envs[local.env_name])
}
