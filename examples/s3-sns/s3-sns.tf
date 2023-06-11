provider "aws" {
}

module "coralogix-shipper-sns" {
  source = "coralogix/aws/coralogix//modules/s3-sns"

  coralogix_region = "Europe"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable       = "false"
  application_name = "s3-sns"
  subsystem_name   = "logs"
  sns_topic_name   = "test-sns-topic-name"
  s3_bucket_name   = "test-bucket-name"
  integration_type = "s3-sns"
}