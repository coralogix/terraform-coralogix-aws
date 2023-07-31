# s3

Manage the application which retrieves logs from `S3` bucket and sends them to your *Coralogix* account. The application can also work with cloudtrail and vpc-flow-logs logs, that will be send to the s3. The application could also be triggered by an SNS topic.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.


### use the defulet s3 integration
```hcl
provider "aws" {
}

module "coralogix-shipper-s3" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3"
}
```

### use the cloudtrail integration
```hcl
module "coralogix-shipper-cloudtrail" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "cloudtrail"
}
```

### use the vpc-flow-logs integration
```hcl
module "coralogix-shipper-vpc-flow-logs" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "vpc-flow-logs"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "vpc-flow-logs"
}
```

### use the s3-sns integration
```hcl
module "coralogix-shipper-sns" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3-sns"
  subsystem_name     = "logs"
  sns_topic_name     = "test-sns-topic-name"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3-sns"
}
```

### use the cloudtrail-sns integration
```hcl
module "coralogix-shipper-cloudtrail-sns" {
  source = "coralogix/aws/coralogix//modules/s3"

  coralogix_region   = "Europe"
  private_key        = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail-sns"
  subsystem_name     = "logs"
  sns_topic_name     = "test-sns-topic-name"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "cloudtrail-sns"
}
```

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Run `terraform destroy` when you don't need these resources.

