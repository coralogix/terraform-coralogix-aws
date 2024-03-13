# Coralogix-Lambda-Manager

This Lambda Function was created to pick up newly created and existing log groups and attach them to Firehose or Lambda integration

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "lambda-manager" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  regex_pattern    = ".*"
  destination_arn  = <your destination lambda/firehose arn>
  logs_filter      = "custome-test"
  destination_type = "lambda"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
