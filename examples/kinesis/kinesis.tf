provider "aws" {
}

module "kinesis" {
  source = "coralogix/aws/coralogix//modules/kinesis"

  coralogix_region    = "Europe"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name    = "kinesis"
  subsystem_name      = "logs"
  kinesis_stream_name = "<your kinesis stream name>"
}
