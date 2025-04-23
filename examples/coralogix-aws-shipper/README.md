# coralogix-aws-shipper

Coralogix provides a predefined AWS Lambda function to easily forward your logs to the Coralogix platform.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

[//]: # (example id="S3-integration")

## Configuration examples

### S3 (default)
```bash
provider "aws" {}

module "coralogix-shipper-s3" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
}
```

### CloudTrail-SNS
```bash
module "coralogix-shipper-cloudtrail" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudTrail"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail-sns"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  sns_topic_name     = "The name of your sns topic"
}
```

### S3Csv
```bash
module "coralogix-shipper-S3Csv" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3Csv"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "S3Csv"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  cs_delimiter       = ","
}
```

### S3-SNS
- In this example, you deploy the S3 integration via SNS and set the subsystem to the value of a log field. For instance, if we send this log:
- In this example, the value of the subsystem will be set to "Subsystem name.”
```hcl
{
    timestamp: "2024-01-01T00:00:01Z"
    massage: "log massage"
    dynamic:
      field: "Subsystem name"
}
```

```bash
module "coralogix-shipper-sns" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3-sns"
  subsystem_name     = "$.dynamic.field"
  s3_bucket_name     = "test-bucket-name"
  sns_topic_name     = "test-sns-topic-name"
}
```

### CloudTrail-SNS with the dynamic subsystem name
- When you set the subsystem to $.eventSource, the subsystem value will be populated with the name of your Trail.
```bash
module "coralogix-shipper-cloudtrail" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudTrail"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail"
  subsystem_name     = "$.eventSource"
  s3_bucket_name     = "test-bucket-name"
}
```

### Vpc Flow
```bash
module "coralogix-shipper-vpcflow" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "VpcFlow"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "vpcflow-application"
  subsystem_name     = "vpcflow-subsystem"
  s3_bucket_name     = "test-bucket-name"
}
```

### Multiple simultaneous S3 integrations using the `integration_info` variable

This example illustrates creation of the following Lambda functions: 

- CloudTrail integration
- VPC Flow integration
- S3 integration with a prefix

```bash
module "coralogix-shipper-multiple-s3-integrations" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  s3_bucket_name     = "bucket name"
  integration_info = {
    "CloudTrail_integration" = {
      integration_type = "CloudTrail"
      application_name = "CloudTrail_application"
      subsystem_name   = "logs_from_cloudtrail"
      api_key          = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
    }
    "VpcFlow_integration" = {
      integration_type = "VpcFlow"
      application_name = "VpcFlow_application"
      subsystem_name   = "logs_from_vpcflow"
      api_key          = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
    }
    "S3_integration" = {
      integration_type = "S3"
      application_name = "s3_application"
      subsystem_name   = "s3_vpcflow"
      s3_key_prefix    = "s3_prefix"
      api_key          = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
    }
  }
}
```  

[//]: # (/example)

[//]: # (example id="CloudWatch-integration")
## Configuration examples

### CloudWatch (default)
```bash
module "coralogix-shipper-cloudwatch" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudWatch"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudwatch-application"
  subsystem_name     = "cloudwatch-subsystem"
  log_groups         = ["log_gruop"]
}
```

### CloudWatch with lambda-manager

In some cases, you will have a large number of log groups that you would like to monitor.
In this case, instead of adding the log groups manually, you can use the lambda-manager to add a subscription to your coralogix-shipper lambda using a regex.
Pay attention that the lambda-manager will also add new log groups to the integration automatically.
For more information, please refer to the [lambda-manager](https://github.com/coralogix/terraform-coralogix-aws/blob/master/modules/lambda-manager/README.md)
```bash
module "coralogix-shipper-cloudwatch" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudWatch"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudwatch-application"
  subsystem_name     = "cloudwatch-subsystem"
  log_groups         = ["log_gruop"]
}

module "coralogix-lambda-manager" {
  source = "coralogix/aws/coralogix//modules/lambda-manager"

  regex_pattern                = "log_groups_name*"
  destination_arn              = module.coralogix-shipper-cloudwatch.lambda_function_arn[0]
  destination_type             = "lambda"
  scan_old_loggroups           = true
  log_group_permissions_prefix = ["log_groups_name"]
}

```
Important note: the `log_group_permissions_prefix` is optional, and will ONLY add permissions to the lambda and will not add the subscription.
For more information about the variables, please refer to the [lambda-manager README](https://github.com/coralogix/terraform-coralogix-aws/tree/master/modules/lambda-manager#environment-variables)

[//]: # (/example)

[//]: # (example id="Kinesis-integration")

### Configuration example
```bash
module "coralogix-shipper-kinesis" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region    = "EU1"
  integration_type    = "Kinesis"
  api_key             = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name    = "kinesis-application"
  subsystem_name      = "kinesis-subsystem"
  kinesis_stream_name = "kinesis-stream-name"
}
```

[//]: # (/example)

[//]: # (example id="MSK-integration")

### Configuration example
```bash
module "coralogix-shipper-msk" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region  = "EU1"
  integration_type  = "MSK"
  api_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name  = "msk-application"
  subsystem_name    = "msk-subsystem"
  msk_cluster_arn   = "msk-cluster-arn"
  msk_topic_name    = "msk-topic-name"
}
```

[//]: # (/example)

[//]: # (example id="EcrScan-integration")

### Configuration example
```bash
module "coralogix-shipper-ecrscan" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region  = "EU1"
  integration_type  = "EcrScan"
  api_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name  = "ecrscan-application"
  subsystem_name    = "ecrscan-subsystem"
}
```

[//]: # (/example)

[//]: # (example id="Kafka-integration")

### Configuration example
```bash
module "coralogix-shipper-kafka" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region  = "EU1"
  integration_type  = "Kafka"
  api_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name  = "kafka-application"
  subsystem_name    = "kafka-subsystem"
  kafka_brokers     = "kafka-broker-1,kafka-broker-2"
  kafka_topic       = "kafka-topic-name"
  kafka_subnets_ids = ["kafka-subnet-1", "kafka-subnet-2"]
  kafka_security_groups = ["kafka-security-group-1", "kafka-security-group-2"]
  ]
}
```

[//]: # (/example)

[//]: # (example id="SQS-integration")

### Configuration example
```bash
module "coralogix-shipper-Sqs" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region  = "EU1"
  integration_type  = "Sqs"
  api_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name  = "sqs-application"
  subsystem_name    = "sqs-subsystem"
  sqs_topic_name    = "sqs-topic-name"
  ]
}
```

[//]: # (/example)

[//]: # (example id="SNS-integration")

## Configuration examples

### SNS (default)
```bash
module "coralogix-shipper-sns" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region  = "EU1"
  integration_type  = "Sns"
  api_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name  = "sns-application"
  subsystem_name    = "sns-subsystem"
  sns_topic_name    = "sns-topic-name"
  ]
}
```

### SNS with a filter policy by `account-id`
```bash
module "coralogix-shipper-sns-with-filter" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region  = "EU1"
  integration_type  = "Sns"
  api_key           = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name  = "sns-application"
  subsystem_name    = "sns-subsystem"
  sns_topic_name    = "sns-topic-name"
  sns_topic_filter_scope = "MessageBody"
  sns_topic_filter_policy = {
    "account-id" = ["123456789012"]
  }
}
```

[//]: # (/example)

### Kinesis with a private link
```bash
module "coralogix-shipper-kinesis" {
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region    = "EU1"
  integration_type    = "Kinesis"
  api_key             = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name    = "kinesis-application"
  subsystem_name      = "kinesis-subsystem"
  kinesis_stream_name = "kinesis-stream-name"
  subnet_ids          = ["subnet-1", "subnet-2"]
  security_group_ids  = ["security-group-1", "security-group-2"]
}
```

### CloudWatch metrics stream via a private link
```bash
module "coralogix_firehose_metrics_private_link" {
  source             = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"
  telemetry_mode     = "metrics"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "firehose_metrics_private_link_application"
  subsystem_name     = "firehose_metrics_private_link_subsystem"
  coralogix_region   = "EU1"
  s3_bucket_name     = "test-bucket-name"
  subnet_ids         = ["subnet-1", "subnet-2"]
  security_group_ids = ["security-group-1", "security-group-2"]

  include_metric_stream_filter = [
    {
      namespace    = "AWS/EC2"
      metric_names = ["CPUUtilization", "NetworkOut"]
    },
    {
      namespace    = "AWS/S3"
      metric_names = ["BucketSizeBytes"]
    },
  ]
}
```

[//]: # (static-examples-readme-start-description)

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Run `terraform destroy` when you don't need these resources.

[//]: # (/static-examples-readme-start-description)
