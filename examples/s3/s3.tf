provider "aws" {
}

module "coralogix-shipper" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region = "Europe"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable       = "false"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "test-bucket-name"
  integration_type = "s3"
}