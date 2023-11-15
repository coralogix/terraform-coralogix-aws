# AWS Coralogix Terraform modules

## Examples

### s3:

```hcl
provider "aws" {
}

module "coralogix-shipper-s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
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

### cloudwatch-logs:

To run this example you need to save this code in Terraform file, and change the values according to our settings.

```hcl
provider "aws" {
}

module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
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

### ECS-EC2

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.
For parameter details, see [ECS-EC2 module README](./modules/ecs-ec2/README.md)

```hcl
module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "ecs-cluster-name"
  image_version            = "latest"
  memory                   = numeric MiB
  coralogix_region         = ["Europe"|"Europe2"|"India"|"Singapore"|"US"|"US2"]
  custom_domain            = "[optional] custom Coralogix domain"
  default_application_name = "Coralogix Application Name"
  default_subsystem_name   = "Coralogix Subsystem Name"
  api_key                  = var.api_key
  otel_config_file         = "[optional] file path to custom OTEL collector config file"
  metrics                  = [true|false]
}
```

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.

### kinesis:

```hcl
provider "aws" {
}

module "kinesis" {
  source = "coralogix/aws/coralogix//modules/kinesis"

  coralogix_region    = "Europe"
  private_key         = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
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

### firehose:

```hcl
provider "aws" {
}

module "cloudwatch_firehose_coralogix" {
  source = "coralogix/aws/coralogix//modules/firehose"

  coralogix_region      = "ireland"
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

### resource-metadata:

```hcl
provider "aws" {
}

module "coralogix-resource-metadata" {
  source = "coralogix/aws/coralogix//modules/resource-metadata"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
}
```
now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

## Modules

### Integrations

- [cloudwatch-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudwatch-logs) - Send logs from `CloudWatch`.
- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3) - Send logs from `S3` bucket.
- [ecs-ec2](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/ecs-ec2) - Send logs, metrics, traces from OTEL Collector on ECS EC2 container instances.
- [eventbridge](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/eventbridge) - Send logs from `eventbrdge`.
- [firehose-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-logs) -  Send logs streams with `firehose`.
- [firehose-metrics](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-metrics) -  Send metric streams with `firehose`.
- [kinesis](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/kinesis) - Send logs from `kinesis data stream` with lambda.
- [resource-metadata](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/resource-metadata) - Send metadata from your AWS account to coralogix.

### Provisioning

- [s3-archive](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3-archive) - Create s3 archives for coralogix logs and metrics.

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.