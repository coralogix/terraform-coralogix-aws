terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

module "cloudwatch_firehose_coralogix" {
  source                           = "../../"
  firehose_stream                  = var.coralogix_firehose_stream_name
  endpoint_url                     = var.coralogix_endpoint_url
  privatekey                       = var.coralogix_privatekey
  enable_cloudwatch_metricstream   = var.enable_cloudwatch_metricstream
}
