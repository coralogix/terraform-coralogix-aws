# Eventbridge Delivery Stream
Configuration in this directory creates an eventbridge delivery stream with ec2 source only.

## Usage

In this example you need to configure the following variables:
* coralogix_eventbridge_stream_name --> The name of the eventbridge delivery stream
* coralogix_region --> The region of Coralogix account
* coralogix_privatekey --> Coralogix account privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* eventbridge_role_name --> The name of the eventbridge role
* eventbridge_sources --> The services for which we will send events