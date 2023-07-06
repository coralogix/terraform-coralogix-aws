# MSK:

Manage the application which retrieves `MSK Kafka messages (logs)` from `lambda` that sends data to your *Coralogix* account.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "msk" {
  source = "coralogix/aws/coralogix//modules/msk"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "msk"
  subsystem_name     = "msk"
  notification_email = "<your notification email>"
  msk_cluster_arn    = "<your MSK cluster arn>"
  topic              = "<your Kafka topic>"
  msk_stream         = "<your MSK delivery stream name>"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
