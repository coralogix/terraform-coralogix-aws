data "aws_region" "this" {}

resource "aws_lambda_layer_version" "coralogix_smlayer" {
  layer_name               = "coralogix-smlayer"
  description              = "Lambda function layer for using Secret Manager for Data API key safe keeping"
  license_info             = "Apache-2.0"
  compatible_runtimes      = ["nodejs16.x", "nodejs18.x", "nodejs14.x"]
  compatible_architectures = ["x86_64", "arm64"]

  s3_bucket = "coralogix-serverless-repo-${data.aws_region.this.id}"
  s3_key    = "lambda-secretLayer.zip"

}
