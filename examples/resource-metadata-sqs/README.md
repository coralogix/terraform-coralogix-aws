# resource-metadata-sqs

Manage the application which retrieves resource metadata from all Lambda functions and EC2 instances in the target AWS region and sends it to your *Coralogix* account. This is an extended version of the [resource-metadata](../../modules/resource-metadata) module, which uses SQS to make the metadata generation process asynchronous in order to handle a large number of resources.

It's recommended to use this module for environments with more than 5000 Lambda functions (or EC2 instances) in the target AWS region.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {}

module "resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata-sqs"

  coralogix_region    = "EU2"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  event_mode          = "EnabledCreateTrail"
}
```

and then execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
