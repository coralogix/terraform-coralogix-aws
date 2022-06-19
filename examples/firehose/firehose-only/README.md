# Firehose Delivery Stream
Configuration in this directory creates a firehose delivery stream only.
This firehose delivery stream can be used with CloudWatch, CloudTrail, etc..

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* endpoint_url --> The url of the Coralogix endpoint, see [Coralogix Endpoints](https://github.com/coralogix/terraform-coralogix-aws/blob/master/modules/firehose/README.md)
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* enable_cloudwatch_metricstream --> the creation of a [cloudwatch metrics stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) can be disabled by setting this variable to 'false'
