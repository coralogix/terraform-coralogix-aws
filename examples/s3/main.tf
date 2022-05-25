provider "aws" {
  region = "eu-west-1"
}

module "s3" {
  source = "../../modules/s3"

  coralogix_region   = "Europe"
  private_key        = var.private_key
  application_name   = "s3"
  subsystem_name     = "logs"
  newline_pattern    = "(?:\\r\\n|\\r|\\n)"
  buffer_size        = 134217728
  sampling_rate      = 1
  debug              = false
  s3_bucket_name     = var.s3_bucket_name
  memory_size        = 1024
  timeout            = 300
  architecture       = "x86_64"
  notification_email = "notifications@example.com"
  tags = {
    Environment = "production"
  }
}
