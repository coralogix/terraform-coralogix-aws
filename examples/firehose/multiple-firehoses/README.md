# Multiple Firehose Delivery Stream
Configuration in this directory creates multiple firehose delivery streams.
This can be created with CloudWatch metric stream or without. 
In this example it includes a metric stream including all namespaces.

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* endpoint_url --> The url of the Coralogix endpoint, see [Coralogix Endpoints](https://github.com/coralogix/terraform-coralogix-aws/blob/master/modules/firehose/README.md)
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
