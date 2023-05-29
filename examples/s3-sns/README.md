# s3-sns:

```hcl
provider "aws" {
}

module "s3-sns" {
  source = "coralogix/aws/coralogix//modules/s3-sns"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "s3-sns"
  subsystem_name     = "logs"
  sns_topic_name     = "test-sns-topic-name"
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
