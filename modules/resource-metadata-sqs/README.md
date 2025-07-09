# resource-metadata-sqs

Manage the application which retrieves resource metadata from all Lambda functions and EC2 instances in the target AWS region and sends it to your *Coralogix* account. This is an extended version of the [resource-metadata](../resource-metadata) module, which uses SQS to make the metadata generation process asynchronous in order to handle a large number of resources.

Also, it supports:

1. `EventMode` feature, which allows you to use CloudTrail+EventBridge to create new Lambda and EC2 resources in Coralogix near-real-time.
2. Resource metadata collection from multiple accounts and regions.

Read the [docs](https://coralogix.com/docs/integrations/aws/aws-resource-metadata-collection-terraform-module/#high-volume-mode) or [function's README](https://github.com/coralogix/coralogix-aws-serverless/blob/master/src/resource-metadata-sqs/README.md) for more details on how to work with both.

It's recommended to use this module for:

1. Environments with more than 5000 Lambda functions (or EC2 instances) in the target AWS region.
2. Environments that require a support for cross-account and multi-region collection of metadata from multiple AWS accounts.

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
| <a name="module_terraform_aws_modules_lambda_aws"></a> [terraform-aws-modules/lambda/aws](#module\_terraform\_aws\_modules\_lambda\_aws) | >= 7.20.1 |

## Inputs

### Coralogix Configuration Parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`Europe`, `Europe2`, `India`, `Singapore`, `US`, `US2`, `Custom`] | `string` | n/a | yes |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | Your [Coralogix Send Your Data – API Key](https://coralogix.com/docs/send-your-data-api-key/) or incase you use pre created secret (created in AWS secret manager) put here the name of the secret that contains the Coralogix send your data key| `string` | n/a | yes |
| <a name="input_custom_url"></a> [custom_url](#input\_custom\_domain) | Custom url for coralogix for example: https://<your_custom_domain>/api/v1/logs| `string` | n/a | no |

### Event Mode Parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_event_mode"></a> [event\_mode](#input\_event\_mode) | Additionally to the regular schedule, enable real-time processing of CloudTrail events via EventBridge for immediate generation of new resources in Coralogix [Disabled, EnabledWithExistingTrail, EnabledCreateTrail] | `string` | Disabled | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | AWS Organization ID (starts with 'o-'). Leave empty if you want to collect metadata from the current account only. | `string` | n/a | no |

### Cross-account and cross-region parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_source_regions"></a> [source_regions](#input\_source\_regions) | The regions to collect metadata from, separated by commas (e.g. eu-north-1,eu-west-1,us-east-1). Leave empty if you want to collect metadata from the current region only. | `list(string)` | n/a | no |
| <a name="input_crossaccount_mode"></a> [crossaccount_mode](#input\_crossaccount\_mode) | The mode to collect metadata from multiple accounts[Disabled, StaticIAM, Config]. Leave Disabled if you want to collect metadata from the current account only. | `string` | `Disabled` | no |
| <a name="input_crossaccount_config_aggregator"></a> [crossaccount_config_aggregator](#input\_crossaccount\_config\_aggregator) | The name of the AWS Config Aggregator to run the query. Used if `CrossAccountMode` is set to `Config`. | `string` | n/a | no |
| <a name="input_crossaccount_account_ids"></a> [crossaccount_account_ids](#input\_crossaccount\_account\_ids) | The list of account IDs, separated by comma. Used if `CrossAccountMode` is set to `StaticIAM`. | `list(string)` | n/a | no |
| <a name="input_crossaccount_iam_role_name"></a> [crossaccount_iam_role_name](#input\_crossaccount\_iam\_role\_name) | The name of the IAM cross-account roles set in each source account. Used if `CrossAccountMode` is not `Disabled`. | `string` | n/a | no |

### Integration parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The rate to collacet metadata  | `string` | `rate(30 minutes)` | no |
| <a name="input_maximum_concurrency"></a> [maximum_concurrency](#input\_maximum\_concurrency) | Maximum number of concurrent SQS messages to be processed by `generator` lambda after the collection has finished. | `number` | 5 | no |
| <a name="input_latest_versions_per_function"></a> [latest_versions_per_function](#input\_latest\_versions\_per\_function) | How many latest published versions of each Lambda function should be collected  | `number` | 5 | no |
| <a name="input_resource_ttl_minutes"></a> [resource_ttl_minutes](#input\_resource\_ttl\_minutes) | Once a resource is collected, how long should it remain valid | `number` | 60 | no |
| <a name="input_collect_aliases"></a> [collect_aliases](#input\_collect\_aliases) | Collect Aliases | `string` | `false` | no |
| <a name="lambda_function_include_regex_filter"></a> [lambda_function_include_regex_filter](#lambda\_function\_include\_regex\_filter) | If specified, only lambda functions with ARNs matching the regex will be included in the collected metadata | `string` | n/a | no |
| <a name="lambda_function_exclude_regex_filter"></a> [lambda_function_exclude_regex_filter](#lambda\_function\_exclude\_regex\_filter) | If specified, only lambda functions with ARNs NOT matching the regex will be included in the collected metadata | `string` | n/a | no |
| <a name="input_lambda_telemetry_exporter_filter"></a> [lambda_telemetry_exporter_filter](#input\_lambda\_telemetry\_exporter\_filter) | If set to `True`, only lambda functions with `coralogix-telemetry-exporter` layer will be included in the collected metadata | `bool` | `false` | no |
| <a name="lambda_function_tag_filters"></a> [lambda_function_tag_filters](#lambda\_function\_tag\_filters) | If specified, only lambda functions with tags matching the filters will be included in the collected metadata. Values should follow the JSON syntax for --tag-filters as documented [here](https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/get-resources.html#options) | `string` | n/a | no |
| <a name="input_custom_s3_bucket"></a> [custom\_s3\_bucket](#input\_custom\_s3\_bucket) | The name of an existing s3 bucket in your region, in which the lambda zip code will be upload to. | `string` | n/a | no |

### Lambda Configuration Parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory limit | `number` | `256` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout limit | `number` | `300` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture | `string` | `x86_64` | no |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | Failure notification email address | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days) | Retention time of the Cloudwatch log group in which the logs of the lambda function are written to | `number` | `null` | no |

### Security Parameters

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secret_manager_enabled"></a> [secret_manager_enabled](#input\_secret\_manager\_enabled) | Set to true in case that you want to keep your [Coralogix Send Your Data – API Key](https://coralogix.com/docs/send-your-data-api-key/) as a secret in aws secret manager | `bool` | false | no |
| <a name="input_layer_arn"></a> [layer_arn](#input\_layer\_arn) | In case you want to use Secret Manager This is the ARN of the Coralogix [lambda layer](https://serverlessrepo.aws.amazon.com/applications/eu-central-1/597078901540/Coralogix-Lambda-SSMLayer). | `string` | n/a | no |
| <a name="input_create_secret"></a> [create_secret](#input\_create\_secret) | Set to False In case you want to use secrets manager with a predefine secret that was already created and contains Coralogix Send Your Data API key| `string` | True | no |

## Notes

1. In case you use Secret Manager you should first deploy the [SM lambda layer](https://serverlessrepo.aws.amazon.com/applications/eu-central-1/597078901540/Coralogix-Lambda-SSMLayer), you should only deploy one layer per region. Both layers and lambda need to be in the same AWS Region.
2. The `Schedule` parameter needs to be longer than the time it takes to collect the metadata. For example, if it takes 10 minutes to collect the metadata from all lambda functions, the `Schedule` parameter should be set to `rate(15 minutes)` at least.
3. The `ResourceTtlMinutes` parameter needs to be longer than the `Schedule` parameter. For example, if the `Schedule` parameter is set to `rate(15 minutes)`, the `ResourceTtlMinutes` parameter should be set to at least 20 minutes.
4. You shoud use the `custom_s3_bucket` variable only when you need to deploy the integration in aws region that coralogix doesn't have a public bucket in (i.e for GovCloud), when using this variable you will need to create a bucket in the region that you want to run the integration in, and pass this bucket name as `custom_s3_bucket`. The module will download the integration file to your local workspace, and then upload these files to the `custom_s3_bucket`, and remove the file from your local workspace.

## Coralgoix regions
| Coralogix region | AWS Region | Coralogix Domain |
|------|------------|------------|
| `EU1` |  `eu-west-1` | eu1.coralogix.com |
| `EU2` |  `eu-north-1` | eu2.coralogix.com |
| `AP1` | `ap-south-1`  | ap1.coralogix.com |
| `AP2` | `ap-southeast-1` | ap2.coralogix.com |
| `AP3` | `ap-southeast-3` | ap3.coralogix.com |
| `US1` | `us-east-2` | us1.coralogix.com |
| `US2` | `us-west-2` | us2.coralogix.com |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_collector_lambda_function_arn"></a> [collector\_lambda\_function\_arn](#output\_collector\_lambda\_function\_arn) | The ARN of the Collector Lambda Function |
| <a name="output_collector_lambda_function_name"></a> [collector\_lambda\_function\_name](#output\_collector\_lambda\_function\_name) | The name of the Collector Lambda Function |
| <a name="output_collector_lambda_role_arn"></a> [collector\_lambda\_role\_arn](#output\_collector\_lambda\_role\_arn) | The ARN of the IAM role created for the Collector Lambda Function |
| <a name="output_collector_lambda_role_name"></a> [collector\_lambda\_role\_name](#output\_collector\_lambda\_role\_name) | The name of the IAM role created for the Collector Lambda Function |
| <a name="output_generator_lambda_function_arn"></a> [generator\_lambda\_function\_arn](#output\_generator\_lambda\_function\_arn) | The ARN of the Generator Lambda Function |
| <a name="output_generator_lambda_function_name"></a> [generator\_lambda\_function\_name](#output\_generator\_lambda\_function\_name) | The name of the Generator Lambda Function |
| <a name="output_generator_lambda_role_arn"></a> [generator\_lambda\_role\_arn](#output\_generator\_lambda\_role\_arn) | The ARN of the IAM role created for the Generator Lambda Function |
| <a name="output_generator_lambda_role_name"></a> [generator\_lambda\_role\_name](#output\_generator\_lambda\_role\_name) | The name of the IAM role created for the Generator Lambda Function |
| <a name="output_metadata_queue_arn"></a> [metadata\_queue\_arn](#output\_metadata\_queue\_arn) | The ARN of the SQS queue for metadata |
| <a name="output_metadata_queue_url"></a> [metadata\_queue\_url](#output\_metadata\_queue\_url) | The URL of the SQS queue for metadata |
| <a name="output_cloudtrail_bucket_name"></a> [cloudtrail\_bucket\_name](#output\_cloudtrail\_bucket\_name) | The name of the S3 bucket for CloudTrail logs |
| <a name="output_cloudtrail_bucket_arn"></a> [cloudtrail\_bucket\_arn](#output\_cloudtrail\_bucket\_arn) | The ARN of the S3 bucket for CloudTrail logs |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic for failure notifications |
