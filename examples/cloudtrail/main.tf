provider "aws" {
  region = "eu-west-1"
}

module "cloudtrail" {
  source = "../../modules/cloudtrail"

  coralogix_region   = var.coralogix_region
  private_key        = var.private_key
  application_name   = "s3"
  subsystem_name     = "cloudtrail"
  s3_bucket_name     = var.s3_bucket_name
  memory_size        = 1024
  timeout            = 300
  architecture       = "x86_64"
  notification_email = "notifications@example.com"
  tags = {
    Environment = "production"
  }
}
