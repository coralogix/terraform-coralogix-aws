provider "aws" {
}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata"

  coralogix_region    = "Europe"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable          = "false"
  layer_arn           = "<your layer arn>"
}
