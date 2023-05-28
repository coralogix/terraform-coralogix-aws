# AWS Coralogix Terraform module

## Examples

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

# cloudtrail:
To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "cloudtrail" {
  source = "coralogix/aws/coralogix//modules/cloudtrail"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "cloudtrail"
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

Run `terraform destroy` when you don't need these resources.

# cloudtrail-sns:

```hcl
provider "aws" {
}

module "cloudtrail-sns" {
  source = "coralogix/aws/coralogix//modules/cloudtrail-sns"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "cloudtrail-sns"
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

# vpc-flow-logs:

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "vpc_flow_logs" {
  source = "coralogix/aws/coralogix//modules/vpc-flow-logs"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "vpc-flow-logs"
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

Run `terraform destroy` when you don't need these resources.

## Modules

- [cloudtrail](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudtrail) - Send `CloudTrail` logs from `S3` bucket.
- [cloudtrail-sns](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudtrail-sns) - Send `CloudTrail` logs from `S3` bucket through `SNS`.
- [cloudwatch-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudwatch-logs) - Send logs from `CloudWatch`.
- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3) - Send logs from `S3` bucket.
- [s3-sns](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3-sns) - Send logs from `S3` bucket through `SNS`.
- [eventbridge](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/eventbridge) - Send logs from `eventbrdge`.
- [firehose](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose) - Send logs from `firehose`.
- [vpc-flow-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/vpc-flow-logs) - Send `vpc flow logs` logs from `S3` bucket.

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.
