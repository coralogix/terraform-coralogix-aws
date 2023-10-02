# secret-lambdaLayer:

This application will create an SM layer to use in our integrations.
You will need to deploy one layer per AWS Region you want to use.
Currently the layer support only NodeJS runtimes.

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

You can connect this module to your integration as shown below, so you won't need to manually pass the arn.
Please be aware you should not deploy more than one layer per region.

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
  layer_arn          = module.lambda-secretLayer.lambda_layer_version_arn
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3"
}
```

In case you want to use secrets manager with a predefine secret that was already created and contains Coralogix Send Your Data API key set the variable create_secret to False and in private_key put the name of the secret that contains the Coralogix [send your data key](https://coralogix.com/docs/send-your-data-api-key/), as shown below.

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
  private_key        = "the name of the secret that contains the Coralogix send your data key"
  layer_arn          = module.lambda-secretLayer.lambda_layer_version_arn
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3"
  create_secret      = "False"
}
```
