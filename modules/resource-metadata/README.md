# resource-metadata

Manage the application which retrieves `meta data` from your aws account and sends them to your *Coralogix* account.

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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`Europe`, `Europe2`, `India`, `Singapore`, `US`, `US2`, `Custom`] | `string` | n/a | yes |
| <a name="input_custom_url"></a> [custom_url](#input\_custom\_domain) | Custom url for coralogix for example: https://<your_custom_domain>/api/v1/logs| `string` | n/a | no |
| <a name="input_ssm_enable"></a> [ssm_enable](#input\_ssm\_enable\) | store coralogix private_key as a secret so that it will not be save in the lambda True/False. Require that the coralogix ssm layer will be deployed in advance | `string` | `False` | no |
| <a name="input_layer_arn"></a> [layer_arn](#input\_layer\_arn) | Coralogix SSM Layer ARN (if SsmEnabled set to false, can leave as empty). | `string` | n/a | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The Coralogix private key which is used to validate your authenticity | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | The rate to collacet metadata  | `string` | `rate(10 minutes)` | no |
| <a name="input_latest_versions_per_function"></a> [latest_versions_per_function](#input\_latest\_versions\_per\_function) | How many latest published versions of each Lambda function should be collected  | `number` | 5 | no |
| <a name="input_resource_ttl_minutes"></a> [resource_ttl_minutes](#input\_resource\_ttl\_minutes) | Once a resource is collected, how long should it remain valid | `number` | 60 | no |
| <a name="input_collect_aliases"></a> [collect_aliases](#input\_collect\_aliases) | Collect Aliases | `string` | `false` | no |
| <a name="input_blocking_pattern"></a> [blocking\_pattern](#input\_blocking\_pattern) | The pattern for lines blocking | `string` | `""` | no |
| <a name="input_buffer_size"></a> [buffer\_size](#input\_buffer\_size) | Coralogix logger buffer size | `number` | `134217728` | no |
| <a name="input_sampling_rate"></a> [sampling\_rate](#input\_sampling\_rate) | Send messages with specific rate | `number` | `1` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory limit | `number` | `256` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout limit | `number` | `300` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture | `string` | `x86_64` | no |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | Failure notification email address | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

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


