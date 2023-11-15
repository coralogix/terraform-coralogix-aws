provider "aws" {
}

# module "coralogix-shipper" {
#   source = "./modules/s3"

#   coralogix_region = "Europe"
#   api_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
#   application_name = "s3"
#   subsystem_name   = "logs"
#   s3_bucket_name   = "gr-integrations-aws-testing"
#   integration_type = "s3"
# }
module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region = "Europe"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name = "cloudwatch"
  subsystem_name   = "logs"
  log_groups       = ["gr-test"]
}