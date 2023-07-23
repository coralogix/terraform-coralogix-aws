# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

module "cloudwatch" {
  source = "./modules/kinesis"

  coralogix_region = "Europe"
  custom_url = "ingress.staging.coralogix.net"
  private_key      = "743e8f3a-3f0f-7daa-d7b5-19fac2492895"
  ssm_enable       = "false"
  layer_arn        = "arn:aws:lambda:us-east-1:035955823196:layer:coralogix-ssmlayer:21"
  application_name = "kinsis"
  subsystem_name   = "no-ssm"
  kinesis_stream_name = "github-action-test-data-stream"
  }