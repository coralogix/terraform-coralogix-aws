# cloudtrail

Manage the application which retrieves `CloudTrail` logs from `S3` bucket and sends them to your *Coralogix* account.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
terraform {
  required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = ">= 4.15.1"
      }
  }
module "cloudtrail" {
  source = "coralogix/aws/coralogix//modules/cloudtrail"

  coralogix_region   = "Europe"
  CustomDomain       = "https://<your custom doamin>/api/v1/logs"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  SSM_enable         = "false"
  LayerARN           = "<you layer arn>"
  application_name   = "cloudtrail"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
    }
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.


