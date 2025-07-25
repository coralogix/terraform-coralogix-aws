# Firehose Logs Module

Firehose Logs module is designed to support AWS Firehose Logs integration with Coralogix.

## Logs - Usage

### Firehose Delivery Stream

Provision a firehose delivery stream for streaming logs to [Coralogix](https://coralogix.com/docs/aws-firehose/) - add this parameters to the configuration of the integration to enable to stream logs:

```terraform
module "cloudwatch_firehose_logs_coralogix" {
  source                         = "coralogix/aws/coralogix//modules/firehose-logs"
  firehose_stream                = var.coralogix_firehose_stream_name
  api_key                        = var.api_key
  coralogix_region               = var.coralogix_region
  integration_type_logs          = "Default"
  source_type_logs               = "DirectPut"
}
```

### Dynamic Values Table for Logs

For `application_name` and/or `subsystem_name` to be set dynamically in relation to their `integrationType`'s resource fields (e.g. CloudWatch_JSON's loggroup name, EksFargate's k8s namespace). The source's `var` has to be mapped as a string literal to the `integrationType`'s as a DyanamicFromFrield with pre-defined values:

| Field | Source `var` | Expected String Literal | Integration Type | Notes |
|-------|--------------|-------------------------|------------------|-------|
| `applicationName` field in logs | applicationName | `${applicationName}` | Default | need to be supplied in the log to be used |
| `subsystemName` field in logs | subsystemName | `${subsystemName}` | Default |  need to be supplied in the log to be used |
| CloudWatch LogGroup name | logGroup | `${logGroup}` | CloudWatch_JSON <br/> CloudWatch_CloudTrail | supplied by aws |
| `kubernetes.namespace_name` field | kubernetesNamespaceName | `${kubernetesNamespaceName}` | EksFargate | supplied by the default configuration |
| `kubernetes.container_name` field | kubernetesContainerName | `${kubernetesContainerName}` | EksFargate | supplied by the default configuration |
| name part of the `log.webaclId` field | webAclName | `${webAclName}` | WAF | supplied by aws |

As the parameter value expected is in string format of `${var}`, it is required to be escaped with `$$` in terraform to be interpreted as a string literal. For example, to set `subsystem_name` to the `${logGroup}` variable would be `subsystem_name = "$${logGroup}"`.

Note: `RawText` integrationType does not support dynamic values.

For more information - visit [Kinesis Data Firehose - Logs](https://coralogix.com/docs/aws-firehose/).

### Examples
Examples can be found under the [firehose-logs examples directory](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-logs)

## Override Coralogix applicationName and subsystemName
The application name and subsystem name by default is the firehose delivery stream arn and name, but it can be overriden by setting an environment variable called `application_name` and `subsystem_name`. 

# Coralogix account region
The coralogix region variable accepts one of the following regions:
* EU1
* EU2
* AP1
* AP2
* AP3
* US1
* US2

### Coralogix Regions & Description. 

| Region    | Domain                 |  Endpoint                                          |
|-----------|------------------------|----------------------------------------------------|
| EU1       | `eu1.coralogix.com`        | `https://ingress.coralogix.com/aws/firehose`       |
| EU2       | `eu2.coralogix.com`    | `https://ingress.eu2.coralogix.com/aws/firehose`   |
| AP1       | `ap1.coralogix.com`         | `https://ingress.ap1.coralogix.com/aws/firehose`    |
| AP2       | `ap2.coralogix.com`      | `https://ingress.ap2.coralogix.com/aws/firehose`     |
| AP3       | `ap3.coralogix.com`    | `https://ingress.ap3.coralogix.com/aws/firehose`   |
| US1       | `us1.coralogix.com`         | `https://ingress.us1.coralogix.com/aws/firehose`        |
| US2       | `us2.coralogix.com`  | `https://ingress.us2.coralogix.com/aws/firehose` |

### Custom Domain
It is possible to pass a custom coralogix domain by using the `custom_domain` variable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.17.1 |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.17.1 |

## Inputs 

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: EU1, EU2, AP1, AP2, AP3, US1, US2 [exact] | `any` | n/a | yes |
| <a name="input_api_key"></a> [api_key](#input\_api_key) | Coralogix account logs API key | `any` | n/a | yes |
| <a name="input_firehose_stream"></a> [firehose\_stream](#input\_firehose\_stream) | AWS Kinesis firehose delivery stream name | `string` | n/a | yes |
| <a name="input_application_name"></a> [application_name](#input\_application_name) | The name of your application in Coralogix | `string` | n/a | yes |
| <a name="input_subsystem_name"></a> [subsystem_name](#input\_subsystem_name) | The subsystem name of your application in Coralogix | `string` | n/a | yes |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch\_retention\_days](#input\_cloudwatch_retention_days) | Days of retention in Cloudwatch retention days | `number` | n/a | no |
| <a name="input_custom_domain"></a> [custom_domain](#input\_custom_domain) | Custom domain for Coralogix firehose integration endpoint (private.coralogix.net:8443) | `string` | `null` | no |
| <a name="input_source_type_logs"></a> [source_type_logs](#input\_source_type_logs) | The source_type of kinesis firehose: KinesisStreamAsSource or DirectPut | `string` | `DirectPut` | no |
| <a name="input_kinesis_stream_arn"></a> [kinesis_stream_arn](#input\_kinesis_stream_arn) | If 'KinesisStreamAsSource' set as source_type_logs. Set the kinesis stream's ARN as the source of the firehose log stream | `string` | `""` | no |
| <a name="input_integration_type_logs"></a> [integration_type_logs](#input\_integration_type_logs) | The integration type of the firehose delivery stream: 'CloudWatch_JSON', 'WAF', 'CloudWatch_CloudTrail', 'EksFargate', 'Default', 'RawText' | `string` | `Default` | no |
| <a name="input_s3_backup_custom_name"></a> [s3_backup_custom_name](#input\_s3_backup_custom_name) | Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup-logs' will be used | `string` | `null` | no |
| <a name="input_existing_s3_backup"></a> [existing\_s3\_backup](variables.tf#L149) | Use an existing S3 bucket to use as a backup bucket. | `string` | n/a | no |
| <a name="input_govcloud_deployment"></a> [govcloud\_deployment](#input\_govcloud\_deployment) | Enable if you deploy the integration in govcloud | `bool` | false | no |
| <a name="input_firehose_iam_custom_name"></a> [firehose\_iam\_custom\_name](variables.tf#L179) | Set the name of the IAM role & policy, otherwise variable '{firehose_stream}-firehose-metrics-iam' will be used. | `string` | n/a | no |
| <a name="input_existing_firehose_iam"></a> [existing\_firehose\_iam](variables.tf#L185) | Use an existing IAM role to use as a firehose role. | `string` | n/a | no |
| <a name="input_user_supplied_tags"></a> [user_supplied_tags](#input\_user_supplied_tags) | Tags supplied by the user to populate to all generated resources | `map(string)` | n/a | no |
| <a name="input_override_default_tags"></a> [override_default_tags](#input\_override_default_tags) | Override and remove the default tags by setting to true | `bool` | `false` | no |
| <a name="s3_enable_secure_transport"></a> [s3\_enable\_secure\_transport](variables.tf#L105) | Disable if you dont want bucket policy that complies with s3-bucket-ssl-requests-only rule | `bool` | `true` | no |

## Coralgoix regions

| Coralogix region | AWS Region | Coralogix Domain |
|------------------|------------|------------------|
| `Europe` | `eu-west-1` | eu1.coralogix.com |
| `Europe2` | `eu-north-1` | eu2.coralogix.com |
| `India` | `ap-south-1` | ap1.coralogix.com |
| `Singapore` | `ap-southeast-1` | ap2.coralogix.com |
| `AP3` | `ap-southeast-3` | ap3.coralogix.com |
| `US` | `us-east-2` | us1.coralogix.com |
| `US2` | `us-west-2` | us2.coralogix.com |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firehose_stream_arn"></a> [firehose\_stream\_arn](#output\_firehose\_stream\_arn) | ARN of the Firehose Delivery Stream |
| <a name="output_firehose_stream_name"></a> [firehose\_stream\_name](#output\_firehose\_stream\_name) | Name of the Firehose Delivery Stream |
| <a name="output_firehose_iam_role_arn"></a> [firehose\_iam_role\_arn](#output\_firehose\_iam_role\_arn) | ARN of the Firehose IAM role |
| <a name="output_s3_backup_bucket_arn"></a> [s3\_backup\_bucket\_arn](#output\_s3\_backup\_bucket\_arn) | ARN of the Firehose S3 Backup Bucket |

<!-- END_TF_DOCS -->
