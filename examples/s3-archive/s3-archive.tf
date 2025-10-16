provider "aws" {
}

module "s3-archive" {
  source = "coralogix/aws/coralogix//modules/provisioning/s3-archive"

  aws_region          = var.aws_region
  logs_bucket_name    = var.logs_bucket_name
  metrics_bucket_name = var.metrics_bucket_name
}