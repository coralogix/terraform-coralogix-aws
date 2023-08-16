data "aws_region" "this" {}

resource "aws_lambda_layer_version" "coralogix_ssmlayer" {
  layer_name               = "coralogix-ssmlayer"
  description              = "Lambda function layer for using SSM for PrivateKey safe keeping"
  license_info             = "Apache-2.0"
  compatible_runtimes      = ["nodejs16.x", "nodejs18.x", "nodejs14.x"]
  compatible_architectures = ["x86_64", "arm64"]

  s3_bucket = "gr-integrations-aws-testing"
  s3_key    = "wrapper.zip"

}
