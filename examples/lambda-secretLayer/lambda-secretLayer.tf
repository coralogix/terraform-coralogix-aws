provider "aws" {
}

module "lambda-secretLayer" {
  source = "coralogix/aws/coralogix//modules/lambda-secretLayer"

}

output "layer_arn" {
  value = module.lambda-secretLayer.lambda_layer_version_arn
}
