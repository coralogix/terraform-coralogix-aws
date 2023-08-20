# s3-archive

The module s3-archive will create s3 buckets to archive your coralogix logs and metrics

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.

### To run the module
```hcl
provider "aws" {
}

module "s3-archive" {
  source = "coralogix/aws/coralogix//modules/provisioning/s3-archive"

  aws_region          = "<your aws region>"
  logs_bucket_name    = "<your bucket name>"
  metrics_bucket_name = "<your bucket name>"
}
```