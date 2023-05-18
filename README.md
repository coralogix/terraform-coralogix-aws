# AWS Coralogix Terraform module

## Usage

`cloudtrail`:

```hcl
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
```

`cloudwatch-logs`:

```hcl
module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region   = "Europe"
  CustomDomain       = "https://<your custom doamin>/api/v1/logs"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  SSM_enable         = "false"
  LayerARN           = "<you layer arn>"
  application_name   = "cloudwatch"
  subsystem_name     = "logs"
  log_groups         = ["test-log-group"]
}
```

`s3`:

```hcl
module "s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  SSM_enable         = "false"
  LayerARN           = "<you layer arn>"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
}
```

## Examples

- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudtrail) - Send `CloudTrail` logs from `S3` bucket.
- [cloudwatch-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudwatch-logs) - Send logs from `CloudWatch`.
- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3) - Send logs from `S3` bucket.

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.
