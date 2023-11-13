provider "aws" {
}

module "coralogix-shipper" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region                  = "Europe"
  private_key                       = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name                  = "s3"
  subsystem_name                    = "logs"
  s3_bucket_name                    = "test-bucket-name"
  integration_type                  = "s3"
  cloudwatch_logs_retention_in_days = 7   # optional
}
