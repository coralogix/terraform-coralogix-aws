provider "aws" {
}

module "s3-archive" {
  source = "coralogix/aws/coralogix//modules/provisioning/s3-archive"

  aws_region          = "<your coralogix region>"
  logs_bucket_name    = "<your bucket name>"
  metrics_bucket_name = "<your bucket name>"
}