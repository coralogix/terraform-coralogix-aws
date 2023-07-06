provider "aws" {
}

module "msk" {
  source = "coralogix/aws/coralogix//modules/msk"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "msk"
  subsystem_name     = "msk"
  notification_email = "<your notification email>"
  msk_cluster_arn    = "<your MSK cluster arn>"
  topic              = "<your Kafka topic>"
  msk_stream         = "<your MSK delivery stream name>"
}