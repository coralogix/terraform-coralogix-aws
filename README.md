# AWS Coralogix Terraform module

## Examples

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

# s3:

```hcl
provider "aws" {
}

module "s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "s3"
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

# cloudwatch-logs:

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
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


## Modules

- [cloudwatch-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudwatch-logs) - Send logs from `CloudWatch`.
- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3) - Send logs from `S3` bucket.
- [eventbridge](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/eventbridge) - Send logs from `eventbrdge`.
- [firehose](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose) - Send logs from `firehose`.

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.
