# Firehose Delivery Stream with CloudWatch metrics stream including all namespaces 
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream. 
The CloudWatch metrics stream in this example includes [all avilable namespaces](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html) under the same stream.   

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* coralogix_region --> The region of Coralogix account
* private_key --> Coralogix account logs private_key
Since the private_key is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_private_key="your-coralogix-private-key"
