The module s3-archive will create s3 buckets to archive your coralogix logs and metrics

The template can run only on the following regions eu-west-1,eu-north-1,ap-southeast-1,ap-south-1,us-east-2

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.15.1 |

| Variable name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| log_bucket_name | The name of the S3 bucket to create for the logs archive (Leave empty if not needed) | `string` | n/a | no |
| metrics_bucket_name | The name of the S3 bucket to create for the Metrics archive (Leave empty if not needed) | `string` | n/a | no |
| log_kms_enalbed | Use kms encription or not | `boolean` | false | no |
| metrics_kms_enalbed | Use kms encription or not | `boolean` | false | no |
| log_kms_arn | In case that kms_enalbed is true, the arn of your kms | `string` | n/a | no |
| metrics_kms_arn | In case that kms_enalbed is true, the arn of your kms | `string` | n/a | no |

### Run the module
```hcl
provider "aws" {
}

module "s3-archive" {
  source = "coralogix/aws/coralogix//provisioning/s3"

  log_bucket_name = "<your bucket name>"
  log_kms_enalbed = false
  metrics_bucket_name = "<your bucket name>"
  metrics_kms_enalbed = false
}
```