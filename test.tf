provider "aws" {
}

module "coralogix-shipper" {
  source = "./modules/coralogix-aws-shipper"

  coralogix_region = "Europe"
  api_key      = ""
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
  integration_type = "s3"
  store_api_key_in_secrets_manager = true
}
# module "cloudwatch_logs" {
#   source = "./modules/coralogix-aws-shipper"

#   coralogix_region = "Europe"
#   api_key      = ""
#   application_name = "s3"
#   subsystem_name   = "logs"
#   # s3_bucket_name = "gr-integrations-aws-testing"
#   log_groups = ["gr-test"]
#   integration_type = "cloudwatch"
#   architecture = "arm64" 
# }