# AWS Coralogix Terraform module

## Examples

# s3:

```hcl
provider "aws" {
}

module "coralogix-shipper-s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable         = "false"
  layer_arn          = "<your layer arn>"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3"
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


# kinesis:

```hcl
provider "aws" {
}

module "kinesis" {
  source = "coralogix/aws/coralogix//modules/kinesis"

  coralogix_region    = "Europe"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  ssm_enable          = "false"
  layer_arn           = "<your layer arn>"
  application_name    = "kinesis"
  subsystem_name      = "logs"
  kinesis_stream_name = "<your kinesis stream name>"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

# firehose:

```hcl
provider "aws" {
}

module "cloudwatch_firehose_coralogix" {
  source = "coralogix/aws/coralogix//modules/firehose"

  coralogix_region      = "irland"
  private_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name      = "firehose"
  subsystem_name        = "logs-and-metrics"
  firehose_stream       = "<your kinesis stream name>"

  #logs:
  logs_enable           = true
  integration_type_logs = "CloudWatch_JSON"

  #metric:
  metric_enable                  = true
  enable_cloudwatch_metricstream = true
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Modules

- [cloudwatch-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudwatch-logs) - Send logs from `CloudWatch`.
- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3) - Send logs from `S3` bucket.
- [eventbridge](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/eventbridge) - Send logs from `eventbrdge`.
- [firehose](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose) -  Send metrics stream and logs with `firehose`.
- [kinesis](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/kinesis) - Send logs from `kinesis data stream` with lambda.

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.
