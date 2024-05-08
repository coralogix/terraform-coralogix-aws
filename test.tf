provider "aws" {
}

module "coralogix-shipper" {
  source = "./modules/coralogix-aws-shipper"

  coralogix_region = "EU1"
  api_key          = "123456778901234"
  application_name = "TF-cloudwatch"
  subsystem_name   = "TF-cloudwatch"
  integration_type = "CloudWatch"
  log_groups       = ["gr-test"]
  enable_dlq       = true
  dlq_s3_bucket    = "gr-integrations-aws-testing"
  dlq_retry_delay  = 30
  dlq_retry_limit  = 3
  timeout          = 30
  # log_level        = "DEBUG"
}