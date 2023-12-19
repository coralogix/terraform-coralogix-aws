# coralogix-aws-shipper (Beta)

## Overview
Coralogix provides a predefined AWS Lambda function to easily forward your logs to the Coralogix platform.

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


### Coralogix configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`EU1`, `EU2`, `AP1`, `AP2`, `US1`, `US2`, `Custom`] | `string` | n/a | yes |
| <a name="input_custom_domain"></a> [custom_domain](#input\_custom\_domain) | The Custom Domain. If set, will be the domain used to send telemetry (e.g. cx123.coralogix.com)| `string` | n/a | no |
| <a name="input_integration_type"></a> [integration_type](#input\_data\_type) | The integration type. Can be one of: CloudWatch, CloudTrail, VpcFlow, S3, S3Csv,Sns' | `string` | n/a | yes |
| <a name="input_api_key"></a> [api\_key](#input\_api_\_key) | Your Coralogix Send Your Data - [API Key](https://coralogix.com/docs/send-your-data-api-key/) which is used to validate your authenticity, This value can be a Coralogix API Key or an AWS Secret Manager ARN that holds the API Key| `string` | n/a | yes |
| <a name="input_store_api_key_in_secrets_manager"></a> [store\_api\_key\_in\_secrets\_manager](#input\_store\_api\_key\_in\_secrets\_manager) | Store the API key in AWS Secrets Manager.  If this option is set to false, the ApiKey will appear in plain text as an environment variable in the lambda function console.| bool | true | no |
| <a name="application_name"></a> [application\_name](#input\_application\_name) | The [name](https://coralogix.com/docs/application-and-subsystem-names/) of your application. for dynamically value from the log you should use $.my_log.field | string | n\a | yes | 
| <a name="subsystem_name"></a> [subsystem\_name](#input\_subsysten_\_name) | The [name](https://coralogix.com/docs/application-and-subsystem-names/) of your subsystem. for dynamic value from the log you should use $.my_log.field . for CloudWatch log group leave empty | string | n\a | yes |


### Integration S3/CloudTrail/VpcFlow/S3Csv configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket to watch | `string` | n/a | yes |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The S3 path prefix to watch | `string` |  n/a | no |
| <a name="input_s3_key_suffix"></a> [s3\_key\_suffix](#input\_s3\_key\_suffix) | The S3 path suffix to watch | `string` |  n/a` | no |
| <a name="input_csv_delimiter"></a> [csv_delimiter](#input\_csv\_delimiter) | Single Character for using as a Delimiter when ingesting CSV (This value is applied when the s3_csv integration type is selected), e.g. "," or " "  | `string` |  n/a | no |
| <a name="input_newline_pattern"></a> [newline\_pattern](#input\_newline\_pattern) | The pattern for lines splitting | `string` | n/a | no |


### Integration Cloudwatch configuration

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_sns_topic_name"></a> [sns_topic_name](#input\_sns\_topic\_name) | The SNS topic that will contain the SNS subscription, need only if you use the sns integration | `string` |  n/a | no |

### Integration SNS configuration
| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_log_groups"></a> [log\_groups](#input\_log\_groups) | The names of the CloudWatch log groups to watch | `list(string)` | n/a | yes |

### Integration Generic Config (Optional)

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_blocking_pattern"></a> [blocking\_pattern](#input\_blocking\_pattern) | The pattern for lines blocking | `string` | n/a | no |
| <a name="input_sampling_rate"></a> [sampling\_rate](#input\_sampling\_rate) | Send messages with specific rate | `number` | `1` | no |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | Failure notification email address | `string` |  n/a | no |
| <a name="input_custom_s3_bucket"></a> [custom\_s3\_bucket](#input\_custom\_s3\_bucket) | The name of an existing s3 bucket in your region, in which the lambda zip code will be uploaded to. | `string` | n/a | no |


### Lambda configuration (Optional)

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory limit | `number` | `1024` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout limit | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` |  n/a | no |
| <a name="lambda_log_retention"></a> [lambda_log_retention](#lambda\_log\_retention) | CloudWatch log retention days for logs generated by the Lambda function | `number` | 5 | no |
| <a name="log_level"></a> [log_level](#input\_log\_level) | Log level for the Lambda function. Can be one of: INFO, WARNING, ERROR, DEBUG | `string` | INFO | no |



### VPC configuration (Optional)

| Name | Description | Type | Default | Required | 
|------|-------------|------|---------|:--------:|
| <a name="input_subnet_ids"></a> [vpc\_subnet\_ids](#input\_subnet\_ids) | The ID of the subnet with the private_link that the lambda will be created in | `list(string)` | n/a | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | The ID of the security group of the subnet | `list(string)` | n/a | no |

### AWS PrivateLink
To use privatelink please follow the instructions in this [link](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/)

### Note:
* You should use the `custom_s3_bucket` variable only when you need to deploy the integration in aws region that coralogix doesn't have a public bucket in (i.e for GovCloud), when using this variable you will need to create a bucket in the region that you want to run the integration in, and pass this bucket name as `custom_s3_bucket`. The module will download the integration file to your local workspace, and then upload these files to the `custom_s3_bucket`, and remove the file from your local workspace.

### Coralogix Domains
You can see in this [link](https://coralogix.com/docs/coralogix-domain/) what is your coralogix domain.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda Function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the Lambda Function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the IAM role created for the Lambda Function |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | The name of the IAM role created for the Lambda Function |

