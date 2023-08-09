# secret-lambdaLayer:

This application will create an SSM layer to use in our integrations.

## Usage

To run this example you need to save this code in Terraform file.

```hcl
provider "aws" {
}

module "lambda-secretLayer" {
  source = "coralogix/aws/coralogix//modules/lambda-secretLayer"

}

output "layer_arn" {
  value = module.lambda-secretLayer.lambda_layer_version_arn
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

You can connect this module to your integration as shown below, so you won't need to manually past the arn:

```hcl
provider "aws" {
}

module "lambda-secretLayer" {
  source = "coralogix/aws/coralogix//modules/lambda-secretLayer"

}

module "coralogix-shipper-s3" {
  source = "coralogix/aws/coralogix//modules/s3"
  depends_on = [ module.lambda-secretLayer ]

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "True"
  layer_arn          = module.lambda-secretLayer.lambda_layer_version_arn
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3"
}
```