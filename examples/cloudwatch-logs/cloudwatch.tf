provider "aws" {
}

module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region = "Europe"
  private_key      = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable       = "false"
  layer_arn        = "<your layer arn>"
  application_name = "cloudwatch"
  subsystem_name   = "logs"
  log_groups       = ["test-log-group"]
}