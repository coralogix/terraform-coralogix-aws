# coralogix-aws-shipper

## Overview

Our newest AWS integration offers the most seamless way to link up with Coralogix. Using a predefined Lambda function, you can send your AWS logs and events to your Coralogix subscription for in-depth analysis, monitoring, and troubleshooting.

This integration guide shows you how to complete our predefined Lambda function template via Terraform. Your task will be to provide specific configuration parameters, based on the service that you wish to connect. The reference list for these parameters is provided below.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.15.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Version |
|------|---------|
| <a name="module_terraform_aws_modules_lambda_aws"></a> [terraform-aws-modules/lambda/aws](#module\_terraform\_aws\_modules\_lambda\_aws) | >= 3.3.1 |

### Universal Configuration

You need to use an existing Coralogix [Send-Your-Data API key](https://coralogix.com/docs/send-your-data-management-api/) to make the connection. Also, please make sure your integration is [Region-specific](https://coralogix.com/docs/coralogix-domain/). You should always deploy the AWS Lambda function in the same AWS Region as your resource (e.g. the S3 bucket).

**Using the same S3 bucket for more than one integration:**
If you are deploying multiple integrations via the same S3 bucket, you will need to specify parameters for each individual integration via `integration_info`. 

**Note:** If you have an existing Lambda function with an S3 trigger already set up, this Terraform deployment will remove that trigger. This holds for the following integration types on the same S3 bucket: S3, CloudTrail, VpcFlow, S3Csv, or CloudFront.

If you want to avoid this issue, you can deploy in other ways:
  1. Deploy the integration using CF Quick Create or SAR. [Dedicated documentation](https://coralogix.com/docs/coralogix-aws-shipper/).  
  2. Migrate your existing integrations to Terraform and use the `integration_info` variable.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`EU1`, `EU2`, `AP1`, `AP2`, `US1`, `US2`, `Custom`] | `string` | n/a | yes |
| <a name="input_custom_domain"></a> [custom_domain](#input\_custom\_domain) | If you choose a custom domain name for your private cluster, Coralogix will send telemetry from the specified address (e.g. custom.coralogix.com) don't add `ingress.` to the domain .| `string` | n/a | no |
| <a name="input_integration_type"></a> [integration_type](#input\_data\_type) | Choose the AWS service that you wish to integrate with Coralogix. Can be one of: S3, CloudTrail, VpcFlow, CloudWatch, S3Csv, SNS, SQS, Kinesis, CloudFront, MSK, Kafka, EcrScan. | `string` | n/a | yes |
| <a name="input_api_key"></a> [api\_key](#input\_api_\_key) | The Coralogix Send Your Data - [API Key](https://coralogix.com/docs/send-your-data-api-key/) validates your authenticity. This value can be a direct Coralogix API Key or an AWS Secret Manager ARN containing the API Key.| `string` | n/a | yes |
| <a name="input_store_api_key_in_secrets_manager"></a> [store\_api\_key\_in\_secrets\_manager](#input\_store\_api\_key\_in\_secrets\_manager) | Enable this to store your API Key securely. Otherwise, it will remain exposed in plain text as an environment variable in the Lambda function console.| bool | true | no |
| <a name="application_name"></a> [application\_name](#input\_application\_name) | The [name](https://coralogix.com/docs/application-and-subsystem-names/) of your application. for dynamically value from the log you should use `$.my_log.field` | string | n\a | yes | 
| <a name="subsystem_name"></a> [subsystem\_name](#input\_subsysten_\_name) | The [name](https://coralogix.com/docs/application-and-subsystem-names/) of your subsystem. for dynamic value from the log you should use `$.my_log.field` for CloudWatch log group leave empty | string | n\a | yes |

### S3/CloudTrail/VpcFlow/S3Csv Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket to watch. | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The S3 path prefix to watch. | `string` |  n/a | no |
| <a name="input_s3_key_suffix"></a> [s3\_key\_suffix](#input\_s3\_key\_suffix) | The S3 path suffix to watch. | `string` |  n/a | no |
| <a name="input_csv_delimiter"></a> [csv_delimiter](#input\_csv\_delimiter) | Specify a single character to be used as a delimiter when ingesting a CSV file with a header line. This value is applicable when the S3Csv integration type is selected, for example, “,” or ” “.  | `string` |  n/a | no |
| <a name="input_newline_pattern"></a> [newline\_pattern](#input\_newline\_pattern) | nter a regular expression to detect a new log line for multiline logs, e.g., \n(?=\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}.\d{3}). | `string` | n/a | no |
| [integration_info](#additional-parameters-for-integration_info) | A map of integration information. Use this when you want to deploy more then one integration using the same s3 bucket. [Parameters are here.](#integration_info)| `mapping` | n/a | no |

### Additional parameters for integration_info 

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_integration_type"></a> [integration_type](#input\_data\_type) | Choose the AWS service that you wish to integrate with Coralogix. Can be one of: S3, CloudTrail, VpcFlow, S3Csv, CloudFront. | `string` | n/a | yes |
| <a name="application_name"></a> [application\_name](#input\_application\_name) | Specify the [name](https://coralogix.com/docs/application-and-subsystem-names/) of your application. for dynamic values from the log use `$.my_log.field` | string | n\a | yes | 
| <a name="subsystem_name"></a> [subsystem\_name](#input\_subsysten_\_name) | Specify the [name](https://coralogix.com/docs/application-and-subsystem-names/) of your subsystem. For dynamic values from the log use `$.my_log.field` | string | n\a | yes |
| <a name="lambda_log_retention"></a> [lambda_log_retention](#lambda\_log\_retention) | Set the CloudWatch log retention period (in days) for logs generated by the Lambda function. | `number` | 5 | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Name the Lambda function that you want to create. | `string` | n/a | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The S3 path prefix to watch. | `string` |  n/a | no |
| <a name="input_s3_key_suffix"></a> [s3\_key\_suffix](#input\_s3\_key\_suffix) | The S3 path suffix to watch. | `string` |  n/a` | no |
| <a name="input_newline_pattern"></a> [newline\_pattern](#input\_newline\_pattern) | Enter a regular expression to detect a new log line for multiline logs, e.g., \n(?=\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}.\d{3}). | `string` | n/a | no |

### CloudWatch Configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_log_groups"></a> [log\_groups](#input\_log\_groups) | Provide a comma-separated list of CloudWatch log group names to monitor, for example, (log-group1, log-group2, log-group3). | `list(string)` | n/a | yes |

### SNS Configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_sns_topic_name"></a> [sns_topic_name](#input\_sns\_topic\_name) | The SNS topic that will contain the SNS subscription. You need this only if you use the SNS integration. | `string` |  n/a | yes |

### SQS Configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_sqs_topic_name"></a> [sqs_topic_name](#input\_sqs\_topic\_name) | Provide the name of the SQS queue to which you want to subscribe for retrieving messages.| `string` |  n/a | yes |

### Kinesis Configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_kinesis_stream_name"></a> [kinesis_stream_name](#input\_Kinesis_\_stream_\_name) | Provide the name of the Kinesis Stream to which you want to subscribe for retrieving messages.| `string` |  n/a | yes |

### MSK Configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_msk_cluster_arn"></a> [msk_cluster_arn](#input\_msk\_cluster\_arn) | The ARN of the MSK cluster to subscribe to retrieving messages.| `string` |  n/a | yes |
| <a name="input_msk_topic_name"></a> [msk_topic_name](#input\_msk\_topic\_name) | List of The Kafka topic anmes used to store records in your Kafka cluster [\"topic-name1\" ,\"topic-name2\"].| `list of strings` |  n/a | yes |

### Kafka Configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_kafka_brokers"></a> [kafka_brokers](#input\_kafka\_brokers) | Comma Delimited List of Kafka broker to connect to.| `string` |  n/a | yes |
| <a name="input_kafka_topic"></a> [kafka_topic](#input\_kafka\_topic) | The Kafka topic to subscribe to.| `string` |  n/a | yes |
| <a name="input_kafka_subnets_ids"></a> [kafka_subnets_ids](#input\_kafka\_subnets\_ids) | List of Kafka subnets to use when connecting to Kafka.| `list` |  n/a | yes |
| <a name="input_kafka_security_groups"></a> [kafka_security_groups](#input\_kafka\_security\_groups) | List of Kafka security groups to use when connecting to Kafka.| `list` |  n/a | yes |

### Generic Configuration (Optional)

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_add_metadata"></a> [add\_metadata](#input\_add\_metadata) | Add metadata to the log message. Expects comma separated values. Options for S3 are `bucket_name`,`key_name`. For CloudWatch `stream_name` | `string` | n/a | no |
| <a name="input_lambda_name"></a> [lambda\_name](#input\_lambda\_name) | Name the Lambda function that you want to create. | `string` | n/a | no |
| <a name="input_blocking_pattern"></a> [blocking\_pattern](#input\_blocking\_pattern) | Enter a regular expression to identify lines excluded from being sent to Coralogix. For example, use `MainActivity.java:\d{3}` to match log lines with MainActivity followed by exactly three digits. | `string` | n/a | no |
| <a name="input_sampling_rate"></a> [sampling\_rate](#input\_sampling\_rate) | Send messages at a specific rate, such as 1 out of every N logs. For example, if your value is 10, a message will be sent for every 10th log. | `number` | `1` | no |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | A failure notification will be sent to this email address. | `string` |  n/a | no |
| <a name="input_custom_s3_bucket"></a> [custom\_s3\_bucket](#input\_custom\_s3\_bucket) | The name of an existing s3 bucket in your region, in which the lambda zip code will be uploaded to. | `string` | n/a | no |

**Custom S3 Bucket**

You should use the `custom_s3_bucket` variable only when you need to deploy the integration in an AWS Region where Coralogix does not have a public bucket in (i.e for GovCloud). 

When using this variable you will need to create an S3 bucket in the region where you want to run the integration. Then, pass this bucket name as `custom_s3_bucket`. The module will download the integration file to your local workspace, and then upload these files to the `custom_s3_bucket`. At the end, the file will be removed from your local workspace.

### Lambda Configuration (Optional)

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Specify the memory size limit for the Lambda function in megabytes. | `number` | `1024` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Set a timeout limit for the Lambda function in seconds. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Add a map of tags to all resources. | `map(string)` |  n/a | no |
| <a name="lambda_log_retention"></a> [lambda_log_retention](#lambda\_log\_retention) | Set the CloudWatch log retention period (in days) for logs generated by the Lambda function. | `number` | 5 | no |
| <a name="log_level"></a> [log_level](#input\_log\_level) | Specify the log level for the Lambda function, choosing from the following options: INFO, WARN, ERROR, DEBUG. | `string` | INFO | no |
| <a name="cpu_arch"></a> [cpu_arch](#input\_cpu\_arch) | Lambda function CPU architecture could be: arm64 or x86_64 | `string` | arm64 | no |

### VPC Configuration (Optional)

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [vpc\_subnet\_ids](#input\_subnet\_ids) | Specify the ID of the subnet where the integration should be deployed. | `list(string)` | n/a | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Specify the ID of the Security Group where the integration should be deployed. | `list(string)` | n/a | no |

**AWS PrivateLink**

If you want to bypass using the public internet, you can use AWS PrivateLink to facilitate secure connections between your VPCs and AWS Services. This option is available under [VPC Configuration](#vpc-configuration-optional). For additional instructions on AWS PrivateLink, please [follow our dedicated tutorial](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/).


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda Function. |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the Lambda Function. |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the IAM role created for the Lambda Function. |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | The name of the IAM role created for the Lambda Function. |
