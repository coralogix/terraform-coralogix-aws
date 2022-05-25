# AWS Coralogix Terraform module

## Usage

`cloudwatch-logs`:

```hcl
module "cloudwatch_logs" {
  source = "coralogix/aws/coralogix//modules/cloudwatch-logs"

  coralogix_region   = "Europe"
  private_key        = "2f55c873-c0cf-4523-82d4-c3b68ee6cb46"
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
  private_key        = "2f55c873-c0cf-4523-82d4-c3b68ee6cb46"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
}
```

## Examples

- [cloudwatch-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/cloudwatch-logs) - Send `CloudWatch` logs.
- [s3](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3) - Send `S3` logs.

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.
