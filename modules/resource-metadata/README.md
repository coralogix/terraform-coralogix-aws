# resource-metadata

Manage the application which retrieves `meta data` from your aws account and sends them to your *Coralogix* account.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

### Note: 
* in case you use Secret Manager you should first deploy the [SM lambda layer](https://serverlessrepo.aws.amazon.com/applications/eu-central-1/597078901540/Coralogix-Lambda-SSMLayer), you should only deploy one layer per region.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.15.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Version |
|------|---------|
| <a name="module_terraform_aws_modules_lambda_aws"></a> [terraform-aws-modules/lambda/aws](#module\_terraform\_aws\_modules\_lambda\_aws) | >= 3.3.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`Europe`, `Europe2`, `India`, `Singapore`, `US`, `US2`, `Custom`] | `string` | n/a | yes |
| <a name="input_custom_url"></a> [custom_url](#input\_custom\_domain) | Custom url for coralogix for example: https://<your_custom_domain>/api/v1/logs| `string` | n/a | no |
| <a name="input_secret_manager_enabled"></a> [secret_manager_enabled](#input\_secret\_manager\_enabled) | Set to true in case that you want to keep your [Coralogix Send Your Data – API Key](https://coralogix.com/docs/send-your-data-api-key/) as a secret in aws secret manager | `bool` | false | no |
| <a name="input_layer_arn"></a> [layer_arn](#input\_layer\_arn) | In case you want to use Secret Manager This is the ARN of the Coralogix [lambda layer](https://serverlessrepo.aws.amazon.com/applications/eu-central-1/597078901540/Coralogix-Lambda-SSMLayer). | `string` | n/a | no |
| <a name="input_create_secret"></a> [create_secret](#input\_create\_secret) | Set to False In case you want to use secrets manager with a predefine secret that was already created and contains Coralogix Send Your Data API key| `string` | True | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | Your [Coralogix Send Your Data – API Key](https://coralogix.com/docs/send-your-data-api-key/) or incase you use pre created secret (created in AWS secret manager) put here the name of the secret that contains the Coralogix send your data key| `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The rate to collacet metadata  | `string` | `rate(10 minutes)` | no |
| <a name="input_latest_versions_per_function"></a> [latest_versions_per_function](#input\_latest\_versions\_per\_function) | How many latest published versions of each Lambda function should be collected  | `number` | 5 | no |
| <a name="input_resource_ttl_minutes"></a> [resource_ttl_minutes](#input\_resource\_ttl\_minutes) | Once a resource is collected, how long should it remain valid | `number` | 60 | no |
| <a name="input_collect_aliases"></a> [collect_aliases](#input\_collect\_aliases) | Collect Aliases | `string` | `false` | no |
| <a name="lambda_function_include_regex_filter"></a> [lambda_function_include_regex_filter](#lambda\_function\_include\_regex\_filter) | If specified, only lambda functions with ARNs matching the regex will be included in the collected metadata | `string` | n/a | no |
| <a name="lambda_function_exclude_regex_filter"></a> [lambda_function_exclude_regex_filter](#lambda\_function\_exclude\_regex\_filter) | If specified, only lambda functions with ARNs NOT matching the regex will be included in the collected metadata | `string` | n/a | no |
| <a name="lambda_function_tag_filters"></a> [lambda_function_tag_filters](#lambda\_function\_tag\_filters) | If specified, only lambda functions with tags matching the filters will be included in the collected metadata. Values should follow the JSON syntax for --tag-filters as documented [here](https://docs.aws.amazon.com/cli/latest/reference/resourcegroupstaggingapi/get-resources.html#options) | `string` | n/a | no |
| <a name="input_custom_s3_bucket"></a> [custom\_s3\_bucket](#input\_custom\_s3\_bucket) | The name of an existing s3 bucket in your region, in which the lambda zip code will be upload to. | `string` | n/a | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory limit | `number` | `256` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout limit | `number` | `300` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture | `string` | `x86_64` | no |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | Failure notification email address | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_cloudwatch_logs_retention_in_days"></a> [cloudwatch\_logs\_retention\_in\_days](#input\_cloudwatch\_logs\_retention\_in\_days) | Retention time of the Cloudwatch log group in which the logs of the lambda function are written to | `number` | `null` | no |

### Note:
You should use the `custom_s3_bucket` variable only when you need to deploy the integration in aws region that coralogix doesn't have a public bucket in (i.e for GovCloud), when using this variable you will need to create a bucket in the region that you want to run the integration in, and pass this bucket name as `custom_s3_bucket`. The module will download the integration file to your local workspace, and then upload these files to the `custom_s3_bucket`, and remove the file from your local workspace.

## Coralgoix regions
| Coralogix region | AWS Region | Coralogix Domain |
|------|------------|------------|
| `Europe` |  `eu-west-1` | coralogix.com |
| `Europe2` |  `eu-north-1` | eu2.coralogix.com |
| `India` | `ap-south-1`  | coralogix.in |
| `Singapore` | `ap-southeast-1` | coralogixsg.com |
| `US` | `us-east-2` | coralogix.us |
| `US2` | `us-west-2` | cx498.coralogix.com |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda Function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the Lambda Function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the IAM role created for the Lambda Function |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | The name of the IAM role created for the Lambda Function |
