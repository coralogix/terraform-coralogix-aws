locals {
  function_name = "Coralogix-${var.integration_type}-${var.random_string}"

  coralogix_regions = {
    Europe    = "coralogix.com"
    Europe2   = "eu2.coralogix.com"
    India     = "coralogix.in"
    Singapore = "coralogixsg.com"
    US        = "coralogix.us"
    US2       = "cx498.coralogix.com"
  }

  coralogix_domains = {
    Europe    = "coralogix.com"
    Europe2   = "eu2.coralogix.com"
    India     = "coralogix.in"
    Singapore = "coralogixsg.com"
    US        = "coralogix.us"
    US2       = "cx498.coralogix.com"
  }

  coralogix_url_seffix = "/api/v1/logs"

  tags = {
    Provider = "Coralogix"
    License  = "Apache-2.0"
  }

  s3_prefix_map = {
    cloudtrail    = "CloudTrail"
    vpcflow = "vpcflowlogs"
  }

  s3_suffix_map = {
    cloudtrail    = ".json.gz"
    vpcflow = ".log.gz"
  }
}
