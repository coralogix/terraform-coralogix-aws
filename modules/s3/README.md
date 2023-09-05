# s3

Manage the application which retrieves logs from `S3` bucket and sends them to your *Coralogix* account.

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

## Inputs

| Name | Description                                                                                                                                  | Type            | Default | Required |
|------|----------------------------------------------------------------------------------------------------------------------------------------------|-----------------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`Europe`, `Europe2`, `India`, `Singapore`, `US`, `US2`, `Custom`]                       | `string`        | n/a |   yes    |
| <a name="input_custom_url"></a> [custom_url](#input\_custom\_domain) | Custom url for coralogix for example: https://<your_custom_domain>/api/v1/logs                                                               | `string`        | n/a |    no    |
| <a name="input_sns_topic_name"></a> [sns_topic_name](#input\_sns\_topic\_name) | The SNS topic that will contain the SNS subscription, need only if you use the sns interations                                               | `string`        |  |    no    |
| <a name="input_layer_arn"></a> [layer_arn](#input\_layer\_arn) | In case you are using SSM This is the ARN of the Coralogix Security Layer.                                                                   | `string`        | n/a |    no    |
| <a name="input_create_secret"></a> [create_secret](#input\_create\_secret) | Set to False In case you want to use SSM with your secret that contains coralogix Private Key                                                | `string`        | True |    no    |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | Your Coralogix secret key or incase you use your own created secret put here the name of your secret that contains the coralogix Private Key | `string`        | n/a |   yes    |
| <a name="input_custom_s3_bucket"></a> [custom\_s3\_bucket](#input\_custom\_s3\_bucket) | The name of an existing s3 bucket in your region, in which the lambda zip code will be upload to.                                            | `string`        | n/a |    no    |
| <a name="input_buffer_size"></a> [buffer\_size](#input\_buffer\_size) | Coralogix logger buffer size                                                                                                                 | `number`        | `134217728` |    no    |
| <a name="input_sampling_rate"></a> [sampling\_rate](#input\_sampling\_rate) | Send messages with specific rate                                                                                                             | `number`        | `1` |    no    |
| <a name="input_debug"></a> [debug](#debug) | Coralogix logger debug mode                                                                                                                  | `bool`          | `false` |    no    |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The name of the S3 bucket to watch                                                                                                           | `string`        | n/a |   yes    |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory limit                                                                                                                 | `number`        | `1024` |    no    |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout limit                                                                                                                | `number`        | `300` |    no    |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture                                                                                                                 | `string`        | `x86_64` |    no    |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | Failure notification email address                                                                                                           | `string`        | `null` |    no    |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources                                                                                                        | `map(string)`   | `{}` |    no    |
| <a name="log_info"></a> [log_info](#input\_log_info) | A map of tags to add to all resources to log on an S3 bucket.                                                                                | `map(log_info)` | `{}` |   yes    |

Inputs for the log_info map.

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_integration_type"></a> [integration_type](#input\_data\_type) | which service will send the data to the s3, possible options are [`cloudtrail`, `vpc-flow-log`, `s3`, `s3-sns`, `cloudtrail-sns`] | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | n/a | yes |
| <a name="input_subsystem_name"></a> [subsystem\_name](#input\_subsystem\_name) | The subsystem name of your application | `string` | n/a | yes |
| <a name="input_newline_pattern"></a> [newline\_pattern](#input\_newline\_pattern) | The pattern for lines splitting | `string` | `(?:\r\n\|\r\|\n)` | no |
| <a name="input_blocking_pattern"></a> [blocking\_pattern](#input\_blocking\_pattern) | The pattern for lines blocking | `string` | `""` | no |
| <a name="input_s3_key_prefix"></a> [s3\_key\_prefix](#input\_s3\_key\_prefix) | The S3 path prefix to watch | `string` | `null` | no |
| <a name="input_s3_key_suffix"></a> [s3\_key\_suffix](#input\_s3\_key\_suffix) | The S3 path suffix to watch | `string` | `null` | no |


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

| Name                                                                                                  | Description                                                       |
|-------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------|
| <a name="output_lambda_function_arns"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn)    | The list of ARNs of the Lambda Functions                          |
| <a name="output_lambda_function_names"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The list of names of the Lambda Functions                         |
| <a name="output_lambda_role_arns"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn)                | The list of ARNs of the IAM roles created for the Lambda Function |
| <a name="output_lambda_role_names"></a> [lambda\_role\_name](#output\_lambda\_role\_name)             | The list of name of the IAM roles created for the Lambda Function |

