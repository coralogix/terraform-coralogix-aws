# kinesis

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

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The Coralogix location region, possible options are [`Europe`, `Europe2`, `India`, `Singapore`, `US`] | `string` | `Europe` | no |
| <a name="input_custom_url"></a> [custom_url](#input\_custom\_url) | Custom url for coralogix | `string` | n/a | no |
| <a name="input_enable_ssm"></a> [enable_ssm](#input\_enable_\_ssm) | store coralogix private_key as a secret so that it will not be save in the lambda. True/False | `string` | `False` | no |
| <a name="input_layer_arn"></a> [layer_arn](#input\_layer\_arn) | Coralogix SSM Layer ARN (if SsmEnabled set to false, can leave as empty). | `string` | n/a | no |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The Coralogix private key which is used to validate your authenticity | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of your application | `string` | n/a | yes |
| <a name="input_subsystem_name"></a> [subsystem\_name](#input\_subsystem\_name) | The subsystem name of your application | `string` | n/a | yes |
| <a name="input_newline_pattern"></a> [newline\_pattern](#input\_newline\_pattern) | The pattern for lines splitting | `string` | `(?:\r\n\|\r\|\n)` | no |
| <a name="input_blocking_pattern"></a> [blocking\_pattern](#input\_blocking\_pattern) | The pattern for lines blocking | `string` | `""` | no |
| <a name="input_buffer_size"></a> [buffer\_size](#input\_buffer\_size) | Coralogix logger buffer size | `number` | `134217728` | no |
| <a name="input_sampling_rate"></a> [sampling\_rate](#input\_sampling\_rate) | Send messages with specific rate | `number` | `1` | no |
| <a name="input_kinesis_stream_name"></a> [kinesis\_stream\_name](#input\_kinesis\_stream\_name) | The name of the kinesis data stream | `string` | n/a | yes |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Lambda function memory limit | `number` | `1024` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Lambda function timeout limit | `number` | `300` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Lambda function architecture | `string` | `x86_64` | no |
| <a name="input_notification_email"></a> [notification_email](#input\_notification\_email) | Failure notification email address | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
