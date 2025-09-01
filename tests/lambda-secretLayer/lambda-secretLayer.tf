provider "aws" {
  region = "us-east-1"
}

module "lambda-secretLayer" {
  source = "../../modules/lambda-secretLayer"

}

module "coralogix-shipper-s3" {
  depends_on = [module.lambda-secretLayer]
  source     = "../../modules/s3"


  coralogix_region       = "Europe"
  private_key            = "{{ secrets.TESTING_PRIVATE_KEY }}"
  secret_manager_enabled = true
  layer_arn              = module.lambda-secretLayer.lambda_layer_version_arn
  application_name       = "s3"
  subsystem_name         = "logs"
  s3_bucket_name         = "github-action-bucket-testing"
  integration_type       = "s3"
}