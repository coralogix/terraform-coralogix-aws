# secret-lambdaLayer:

This application will create an SMM layer to use in our integrations.

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
