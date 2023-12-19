# coralogix-aws-shipper (Beta)

Coralogix provides a predefined AWS Lambda function to easily forward your logs to the Coralogix platform.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.


### Use the default s3 integration
```bash
provider "aws" {}

module "coralogix-shipper-s3" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
}
```

### Use the cloudtrail-sns integration
```bash
module "coralogix-shipper-cloudtrail" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudTrail"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail-sns"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  sns_topic_name     = "The name of your sns topic"
}
```

### Use the S3Csv integration
#### In this example we show how to use the S3Csv option, we also use an option that allows us to not save the api_key as text in the lambda but direct it to the secret that continues the secret.
```bash
module "coralogix-shipper-S3Csv" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3Csv"
  api_key            = "arn of secret that contain the api_key"
  application_name   = "S3Csv"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  cs_delimiter       = ","
  store_api_key_in_secrets_manager = false
}
```

### Use the s3-sns integration
#### In this example we deploy the s3 integration via sns, we set the subsystem to be a value of a log field for example if send this log:
```hcl
{
    timestamp: "2024-01-01T00:00:01Z"
    massage: "log massage"
    dynamic:
      field: "Subsystem name"
}
```
#### the value of the subsystem will be "Subsystem name"

```bash
module "coralogix-shipper-sns" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "S3"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3-sns"
  subsystem_name     = "$.dynamic.field"
  s3_bucket_name     = "test-bucket-name"
  sns_topic_name     = "test-sns-topic-name"
}
```

### Use the cloudtrail integration with the dynamic subsystem name
#### When you set the subsystem to $.eventSource then the value of subsystem will be the name of your Trail.
```bash
module "coralogix-shipper-cloudtrail" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudTrail"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail"
  subsystem_name     = "$.eventSource"
  s3_bucket_name     = "test-bucket-name"
}
```

### Use the cloudwatch integration with a private link
#### For more information about how to use private link click [here](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/)
```bash
module "coralogix-shipper-cloudwatch" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "EU1"
  integration_type   = "CloudWatch"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudwatch-logs"
  subsystem_name     = "logs"
  log_groups         = ["log_gruop"]
  subnet_ids         = "Your subnet ids"
  security_group_ids = ["Your Security group id"]
}
```

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Run `terraform destroy` when you don't need these resources.

