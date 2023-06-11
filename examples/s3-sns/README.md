# s3-sns:

Manage the application which retrieves logs from `s3` bucket, that are triggered by an SNS notification and sends them to your *Coralogix* account. The application can also work with cloudtrail via sns.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.


```hcl
provider "aws" {
}

module "coralogix-shipper-sns" {
  source = "coralogix/aws/coralogix//modules/s3-sns"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  application_name   = "s3-sns"
  subsystem_name     = "logs"
  sns_topic_name     = "test-sns-topic-name"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3-sns"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
