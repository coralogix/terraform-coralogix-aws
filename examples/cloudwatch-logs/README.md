# Warning: This Lambda Function will be deprecated on May 1st
We recommend using [Coralogix AWS Shipper](https://github.com/coralogix/terraform-coralogix-aws/tree/master/modules/coralogix-aws-shipper)

# cloudwatch-logs

Manage the application which retrieves `CloudWatch` logs and sends them to your *Coralogix* account.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudwatch"
  subsystem_name     = "logs"
  log_groups         = ["test-log-group"]
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

