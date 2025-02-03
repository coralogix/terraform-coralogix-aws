provider "aws" {}

module "resource-metadata-sqs" {
  source = "coralogix/aws/coralogix//modules/resource-metadata-sqs"

  coralogix_region = "EU2"
  api_key          = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  event_mode       = "EnabledCreateTrail"
}
