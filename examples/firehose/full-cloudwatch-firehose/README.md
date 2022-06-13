# Firehose Delivery Stream
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream. 
The CloudWatch metrics stream in this example includes all avilable namespaces under the same stream.   

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* endpoint_url --> The url of the Coralogix endpoint, see [Coralogix Endpoints](https://github.com/coralogix/terraform-coralogix-aws/blob/master/modules/firehose/README.md)
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* include_all_namespaces --> this variable is set to 'true' by default so no need to declare. 
