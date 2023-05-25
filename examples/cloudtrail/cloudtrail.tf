provider "aws" {
}

module "cloudtrail" {
  source = "coralogix/aws/coralogix//modules/cloudtrail"

  coralogix_region = "Europe"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable       = "false"
  layer_arn        = "<your layer arn>"
  application_name = "cloudtrail"
  subsystem_name   = "logs"
  s3_bucket_name   = "test-bucket-name"
}