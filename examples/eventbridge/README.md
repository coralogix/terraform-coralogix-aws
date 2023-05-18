# Eventbridge Delivery Stream
Configuration in this directory creates an eventbridge delivery stream with ec2 source only.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "eventbridge_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/eventbridge"
  eventbridge_stream             = var.coralogix_eventbridge_stream_name
  sources                        = var.eventbridge_sources
  role_name                      = var.eventbridge_role_name
  private_key                    = var.coralogix_privatekey
  coralogix_region               = var.coralogix_region
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
