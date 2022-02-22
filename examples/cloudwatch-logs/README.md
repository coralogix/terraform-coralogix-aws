# cloudwatch-logs example

Setup the application which retrieves `CloudWatch` log group and sends them to your *Coralogix* account.

# Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply \
    -var private_key="45f10c5c-d2e2-4f42-9a35-ae1e21ed1e0c" \
    -var log_group="my-log-group"
```

Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.69 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.1.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch_logs"></a> [cloudwatch\_logs](#module\_cloudwatch\_logs) | ../../modules/cloudwatch-logs | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | The Coralogix private key which is used to validate your authenticity | `string` | n/a | yes |
| <a name="input_log_group"></a> [log\_group](#input\_log\_group) | The name of the CloudWatch log group to watch | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the Lambda Function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the Lambda Function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the IAM role created for the Lambda Function |
| <a name="output_lambda_role_name"></a> [lambda\_role\_name](#output\_lambda\_role\_name) | The name of the IAM role created for the Lambda Function |
