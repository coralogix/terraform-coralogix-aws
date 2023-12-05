# coralogix-aws-shipper

Coralogix provides a predefined AWS Lambda function to easily forward your logs to the Coralogix platform.

The `coralogix-aws-shipper` supports forwarding of logs for the following AWS Services:

* [Amazon CloudWatch](https://docs.aws.amazon.com/cloudwatch/)
* [AWS CloudTrail](https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-log-file-examples.html)
* [Amazon VPC Flow logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs-s3.html)
* AWS Elastic Load Balancing access logs ([ALB](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html), [NLB](https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html) and [ELB](https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/access-log-collection.html))
* [Amazon CloudFront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html)
* [AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/logging-s3.html)
* [Amazon Redshift](https://docs.aws.amazon.com/redshift/latest/mgmt/db-auditing.html#db-auditing-manage-log-files)
* [Amazon S3 access logs](https://docs.aws.amazon.com/AmazonS3/latest/userguide/ServerLogs.html)
* [Amazon VPC DNS query logs](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-query-logs.html)
* [AWS WAF](https://docs.aws.amazon.com/waf/latest/developerguide/logging-s3.html)

Additionally, you can ingest any generic text, JSON and csv logs stored in your S3 bucket

## Usage

To run this example you need to save this code in Terraform file, and change the values according to our settings.


### use the default s3 integration
```bash
provider "aws" {}

module "coralogix-shipper-s3" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "Europe"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3"
}
```

### use the cloudtrail-sns integration
```bash
module "coralogix-shipper-cloudtrail" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "Europe"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail-sns"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  sns_topic_name     = "The name of your sns topic"
  integration_type   = "cloudtrail"
}
```

### use the vpcflow integration
#### In this example we show how to use the vpcflow option, we also use an option that allows us to not save the api_key as text in the lambda but direct it to secret that continues the secret.
```bash
module "coralogix-shipper-vpc-flow-logs" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "Europe"
  api_key            = "arn of secret that contain the api_key"
  application_name   = "vpc-flow-logs"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "vpcflow"
  store_api_key_in_secrets_manager = false
}
```

### use the s3-sns integration
#### In this example we deploy the s3 integration via sns, we set the subsystem to be value of a log field for example if send this log:
```hcl
{
  body:
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

  coralogix_region   = "Europe"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "s3-sns"
  subsystem_name     = "$.dynamic.field"
  sns_topic_name     = "test-sns-topic-name"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "s3-sns"
}
```

### use the cloudtrail-sns integration
```bash
module "coralogix-shipper-cloudtrail" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "Europe"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudtrail"
  subsystem_name     = "logs"
  s3_bucket_name     = "test-bucket-name"
  integration_type   = "cloudtrail-sns"
}
```

### use the cloudwatch integration with private link
#### For more information about how to use private link click [here](https://coralogix.com/docs/coralogix-amazon-web-services-aws-privatelink-endpoints/)
```bash
module "coralogix-shipper-cloudwatch" 
{
  source = "coralogix/aws/coralogix//modules/coralogix-aws-shipper"

  coralogix_region   = "Europe"
  api_key            = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
  application_name   = "cloudwatch-logs"
  subsystem_name     = "logs"
  log_groups         = ["log_gruop"]
  integration_type   = "cloudwatch"
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

