provider "aws" {
}

module "vpc-flow-logs" {
  source = "coralogix/aws/coralogix//modules/vpc-flow-logs"

  coralogix_region = "Europe"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable       = "false"
  layer_arn        = "<your layer arn>"
  application_name = "vpc-flow-logs"
  subsystem_name   = "logs"
  s3_bucket_name   = "test-bucket-name"
}
