provider "aws" {
}

module "eventbridge_coralogix" {
  source             = "github.com/coralogix/terraform-coralogix-aws//modules/eventbridge"
  eventbridge_stream = var.coralogix_eventbridge_stream_name
  sources            = var.eventbridge_sources
  role_name          = var.eventbridge_role_name
  private_key        = var.coralogix_privatekey
  coralogix_region   = var.coralogix_region
}