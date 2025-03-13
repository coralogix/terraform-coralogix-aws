# coralogix-aws-shipper

Coralogix provides a predefined AWS Lambda function to easily forward your logs to the Coralogix platform.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

[//]: # (example id="s3-integration")

### Use the default s3 integration
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

### Use the cloudtrail-sns integration
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

### Use the S3Csv integration
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

### Use the s3-sns integration
#### In this example we deploy the s3 integration via sns, we set the subsystem to be a value of a log field for example if send this log:
```hcl
{
    timestamp: "2024-01-01T00:00:01Z"
    massage: "log massage"
    dynamic:
      field: "Subsystem name"
}
```
#### the value of the subsystem will be "Subsystem name"

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

### Use the cloudtrail integration with the dynamic subsystem name
#### When you set the subsystem to $.eventSource then the value of subsystem will be the name of your Trail.
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

### Use the VpcFlow integration
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

### Use the multiple s3 integrations at once using the integration_info variable
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
### This example will create three lambda functions: 1 for CloudTrail integration, 1 for VpcFlow integration, and 1 for S3 integration with a prefix

[//]: # (/example)

[//]: # (example id="cloudwatch-integration")

### Use the CloudWatch integration
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

[//]: # (/example)

[//]: # (example id="kinesis-integration")

### Use the Kinesis integration
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

[//]: # (example id="msk-integration")

### Use the MSK integration
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

[//]: # (example id="ecrscan-integration")

### Use the EcrScan integration
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

[//]: # (example id="kafka-integration")

### Use the Kafka integration
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

[//]: # (example id="sqs-integration")

### Use the SQS integration
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

[//]: # (example id="sns-integration")

### Use the SNS integration
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

[//]: # (/example)

### Use Kinesis with a private link
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

### Use the CloudWatch metrics stream via a private link
```bash
module "coralogix_aws_shipper" "coralogix_firehose_metrics_private_link" {
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
