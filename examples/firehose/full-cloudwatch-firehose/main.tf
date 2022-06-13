terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

module "cloudwatch_firehose_coralogix" {
  source                           = "../../modules/firehose"
  firehose_stream                  = var.coralogix_firehose_stream_name
  endpoint_url                     = var.coralogix_endpoint_url
  privatekey                       = var.coralogix_privatekey
}
