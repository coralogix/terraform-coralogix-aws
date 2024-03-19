# Warning: This Lambda Function will be deprecated on May 1st
We recommend using [Coralogix AWS Shipper](https://github.com/coralogix/terraform-coralogix-aws/tree/master/modules/coralogix-aws-shipper)

# kinesis:

Manage the application which retrieves `Kinesis data stream` from `lambda` that sends data to your *Coralogix* account.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "kinesis" {
  source = "coralogix/aws/coralogix//modules/kinesis"

  coralogix_region    = "Europe"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name    = "kinesis"
  subsystem_name      = "logs"
  kinesis_stream_name = "<your kinesis stream name>"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
