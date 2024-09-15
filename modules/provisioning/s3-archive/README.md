# s3-archive

The module s3-archive will create s3 buckets to archive your coralogix logs and metrics

The module can run only on the following regions eu-west-1,eu-north-1,ap-southeast-1,ap-southeast-3,ap-south-1,us-east-2.

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
|---------------|-------------|------|---------|:--------:|
| aws_region | The AWS region that you want to create the S3 bucket, Must be the same as the AWS region where your [coralogix account](https://coralogix.com/docs/coralogix-domain/) is set. Allowd values: eu-west-1, eu-north-1, ap-southeast-1,ap-southeast-1, ap-south-1, us-east-2, us-west-2 | `string` | n/a | :heavy_check_mark: |
| logs_bucket_name | The name of the S3 bucket to create for the logs archive (Leave empty if not needed), Note: bucket name must follow [AWS naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html) | `string` | n/a | |
| metrics_bucket_name | The name of the S3 bucket to create for the metrics archive (Leave empty if not needed), Note: bucket name must follow [AWS naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html) | `string` | n/a | |
| logs_bucket_force_destroy | enable force destroy to the logs S3 bucekt, to not allow delete if there is files in the bucket | `bool` | false | |
| metrics_bucket_force_destroy | enable force destroy to the metrics S3 bucekt, to not allow delete if there is files in the bucket | `bool` | false | |
| logs_kms_arn |  The arn of your kms for the logs bucket , Note: make sure that the kms is in the same region as your bucket | `string` | n/a | |
| metrics_kms_arn | The arn of your kms for the metrics bucket , Note: make sure that the kms is in the same region as your bucket | `string` | n/a | |