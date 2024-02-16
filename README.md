# AWS Coralogix Terraform modules

Coralogix provides multiple Terraform modules that allows you to send your metrics and logs from AWS to your coralogix account using AWS lambda

## Integrations
Coralogix provides the following integration:

### coralogix-aws-shipper
AWS Lambda function used to send logs from different AWS services like S3/Kinesis/CloudWatch/etc - [coralogix-aws-shipper](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/coralogix-aws-shipper)


### ecs-ec2:
The Coralogix OpenTelemetry Agent for ECS-EC2 Terraform module deploys the Coralogix Distribution for Open Telemetry ("CDOT") Collector Agent as a Daemon ECS service on each EC2 container instance - [ecs-ec2](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/ecs-ec2)

### firehose-logs:
Firehose Logs module is designed to support AWS Firehose Logs integration with Coralogix - [firehose-logs](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-logs)

### firehose-metrics:
Firehose Metrics module is designed to support AWS Firehose Metrics integration with Coralogix. Leveraging AWS CloudWatch Metrics Stream - [firehose-metrics](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-metrics) 

### resource-metadata:
Send metadata from your AWS account to coralogix - [resource-metadata](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/resource-metadata)

### eventbridge
Send aws events to your coralogix account - [eventbridge](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/eventbridge)


# provisioning

### s3-archive
Create s3 archives for coralogix logs and metrics - [s3-archive](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/s3-archive)

## Authors

Module is maintained by [Coralogix](https://github.com/coralogix).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/coralogix/terraform-coralogix-aws/tree/master/LICENSE) for full details.
