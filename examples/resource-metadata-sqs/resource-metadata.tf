provider "aws" {}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata-sqs"

  coralogix_region = "EU2"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  event_mode       = "EnabledCreateTrail"
}
