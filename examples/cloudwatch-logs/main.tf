provider "aws" {
  region = "eu-west-1"
}

module "cloudwatch_logs" {
  source = "../../modules/cloudwatch-logs"

  coralogix_region   = "Europe"
  private_key        = var.private_key
  application_name   = "cloudwatch"
  subsystem_name     = "logs"
  newline_pattern    = "(?:\r\n|\r|\n)"
  buffer_charset     = "utf8"
  sampling_rate      = "1"
  log_group          = var.log_group
  memory_size        = 1024
  timeout            = 300
  architecture       = "x86_64"
  notification_email = "notifications@example.com"
  tags = {
    Environment = "production"
  }
}
