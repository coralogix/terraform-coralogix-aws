# Multiple Firehose Delivery Stream
Configuration in this directory creates multiple firehose delivery streams.
This can be created with CloudWatch metric stream or without. 
In this example it includes a metric stream including all namespaces.

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* coralogix_region --> The region of Coralogix account
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
