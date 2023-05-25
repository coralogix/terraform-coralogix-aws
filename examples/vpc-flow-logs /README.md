#  vpc-flow-logs

Manage the application which retrieves logs from `vpc-flow-logs` and sends them to your *Coralogix* account.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "vpc-flow-logs" {
  source = "coralogix/aws/coralogix//modules/vpc-flow-logs"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "vpc-flow-logs"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Run `terraform destroy` when you don't need these resources.

