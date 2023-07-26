The module s3-archive will create s3 buckets to archive your coralogix logs and metrics

The module can run only on the following regions eu-west-1,eu-north-1,ap-southeast-1,ap-south-1,us-east-2.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.23 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.15.1 |

| Variable name | Description | Type | Default |
|------|-------------|------|:--------:|
| coralogix_region | The coralogix_region where you want to create the bucket in - must be the same as your aws configure region | `string` | n/a |
| log_bucket_name | The name of the S3 bucket to create for the logs archive (Leave empty if not needed), must fllow AWS nameing rules https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html' | `string` | n/a |
| metrics_bucket_name | The name of the S3 bucket to create for the Metrics archive (Leave empty if not needed), must fllow AWS nameing rules https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html' | `string` | n/a |
| log_kms_arn |  In case that you want to use KMS for logs bucket - the arn of your kms. Make sure that the kms is in the same region as yuor bucket | `string` | n/a |
| metrics_kms_arn | In case that you want to use KMS for metrics bucket - the arn of your kms. Make sure that the kms is in the same region as yuor bucket | `string` | n/a |

### To run the module
```hcl
provider "aws" {
}

module "s3-archive" {
  source = "coralogix/aws/coralogix//provisioning/s3-archive"

  coralogix_region    = "<your coralogix region>"
  log_bucket_name     = "<your bucket name>"
  metrics_bucket_name = "<your bucket name>"
}
```