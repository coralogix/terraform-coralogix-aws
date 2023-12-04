provider "aws" {
}

# module "coralogix-cloudtrail-main" {
#   source           = "./modules/coralogix-aws-shipper"
#   coralogix_region = "Europe"
#   api_key      = ""
#   log_info         = {
#     "cloudtrail-main" = {
#       application_name = "everyonesocial-cloudtrail"
#       subsystem_name   = "cloudtrail-main"
#       integration_type = "cloudtrail"
#     }
#   }
#   s3_bucket_name = "gr-integrations-aws-testing"
# }


module "coralogix-shipper" {
  source = "./modules/coralogix-aws-shipper"
  store_api_key_in_secrets_manager = false
  api_key = ""

  # source = "coralogix/aws/coralogix//modules/s3"
  # private_key      = ""
  coralogix_region = "Europe"
  application_name = "s3-vpc-flow-logs"
  subsystem_name   = "logs-flow-logs"
  s3_bucket_name   = "gr-integrations-aws-testing"
  # sns_topic_name = "gr-sns-topic"
  integration_type = "vpcflow"
    log_info         = {
    "cloudtrail-main" = {
      application_name = "everyonesocial-cloudtrail"
      subsystem_name   = "cloudtrail-main"
      integration_type = "cloudtrail"
    }
  }
}


# module "cloudwatch_logs" {
#   source = "./modules/coralogix-aws-shipper"

#   coralogix_region = "Europe"
#   api_key      = ""
#   application_name = "cloudwatch"
#   subsystem_name   = "logs"
#   # s3_bucket_name = "gr-integrations-aws-testing"
#   log_groups = ["gr-test"]
#   integration_type = "cloudwatch"
#   # architecture = "arm64" 
#   store_api_key_in_secrets_manager = false
# }