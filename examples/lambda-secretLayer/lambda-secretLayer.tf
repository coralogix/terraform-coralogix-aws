provider "aws" {
}

module "ssm-secret-layer" {
  source = "coralogix/aws/coralogix//modules/secret-lambdaLayer"

}

output "layer_arn" {
  value = module.ssm-secret-layer.lambda_layer_version_arn
}