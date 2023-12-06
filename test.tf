provider "aws" {
}

module "coralogix-shipper" {
  source = "./modules/coralogix-aws-shipper"
  # store_api_key_in_secrets_manager = false
  # api_key = ""

  # source = "coralogix/aws/coralogix//modules/s3"
  api_key      = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
  coralogix_region = "Europe"
  # application_name = "s3-vpc-flow-logs"
  # subsystem_name   = "logs-flow-logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
  # # sns_topic_name = "gr-sns-topic"
  # integration_type = "vpcflow"
  application_name = "everyonesocial-cloudtrail"
  subsystem_name   = "cloudtrail-main"
  integration_type = "CloudTrail"
}


# module "cloudwatch_logs" {
#   source = "./modules/coralogix-aws-shipper"

#   coralogix_region = "Europe"
#   api_key      = "2fa1aadf-d7dd-f7a1-253c-7a8b14e6409c"
#   application_name = "cloudwatch"
#   subsystem_name   = "logs"
#   # s3_bucket_name = "gr-integrations-aws-testing"
#   log_groups = ["gr-test"]
#   integration_type = "CloudWatch"
#   # architecture = "arm64" 
#   store_api_key_in_secrets_manager = false
# }