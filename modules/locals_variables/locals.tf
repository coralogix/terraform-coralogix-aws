locals {
  function_name = "Coralogix-${var.integration_type}-${var.random_string}"

  coralogix_regions = {
    Europe    = "ingress.coralogix.com"
    Europe2   = "ingress.eu2.coralogix.com"
    India     = "ingress.coralogix.in"
    Singapore = "ingress.coralogixsg.com"
    US        = "ingress.coralogix.us"
    US2       = "ingress.cx498.coralogix.com"
    AP3       = "ap3.coralogix.com"
  }

  coralogix_domains = {
    Europe    = "coralogix.com"
    EU1       = "coralogix.com"
    ireland   = "coralogix.com"
    Europe2   = "eu2.coralogix.com"
    stockholm = "eu2.coralogix.com"
    EU2       = "eu2.coralogix.com"
    India     = "coralogix.in"
    india     = "coralogix.in"
    AP1       = "coralogix.in"
    Singapore = "coralogixsg.com"
    singapore = "coralogixsg.com"
    AP2       = "coralogixsg.com"
    US        = "coralogix.us"
    us        = "coralogix.us"
    US1       = "coralogix.us"
    US2       = "cx498.coralogix.com"
    us2       = "cx498.coralogix.com"
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
