provider "aws" {
}

module "coralogix-shipper" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region = "EU1"
  api_key          = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name = "s3"
  subsystem_name   = "logs"
  s3_bucket_name   = "test-bucket-name"
  integration_type = "S3"
  # create_sns_topic_policy = true  # Default: module manages SNS topic policy
}
