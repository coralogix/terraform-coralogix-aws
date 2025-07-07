locals {
  function_name = "Coralogix-${var.integration_type}-${var.random_string}"

  coralogix_regions = {
    Europe    = "ingress.eu1.coralogix.com"
    Europe2   = "ingress.eu2.coralogix.com"
    India     = "ingress.ap1.coralogix.com"
    Singapore = "ingress.ap2.coralogix.com"
    US        = "ingress.us1.coralogix.com"
    US2       = "ingress.us2.coralogix.com"
    AP3       = "ap3.coralogix.com"
  }

  coralogix_domains = {
    Europe    = "eu1.coralogix.com"
    EU1       = "eu1.coralogix.com"
    ireland   = "eu1.coralogix.com"
    Europe2   = "eu2.coralogix.com"
    stockholm = "eu2.coralogix.com"
    EU2       = "eu2.coralogix.com"
    India     = "ap1.coralogix.com"
    india     = "ap1.coralogix.com"
    AP1       = "ap1.coralogix.com"
    Singapore = "ap2.coralogix.com"
    singapore = "ap2.coralogix.com"
    AP2       = "ap2.coralogix.com"
    US        = "us1.coralogix.com"
    us        = "us1.coralogix.com"
    US1       = "us1.coralogix.com"
    US2       = "us2.coralogix.com"
    us2       = "us2.coralogix.com"
    AP3       = "ap3.coralogix.com"
  }

  coralogix_url_seffix = "/api/v1/logs"

  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }

  s3_prefix_map = {
    cloudtrail    = "CloudTrail"
    vpc-flow-logs = "vpcflowlogs"
  }

  s3_suffix_map = {
    cloudtrail    = ".json.gz"
    vpc-flow-logs = ".log.gz"
  }
}
