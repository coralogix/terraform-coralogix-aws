# Firehose Delivery Stream
Configuration in this directory creates a firehose delivery stream only for logs.
This firehose delivery stream can be used with CloudWatch, CloudTrail, [etc..](https://coralogix.com/docs/aws-firehose/)

## Usage

In this example you need to configure the following variables:
* `metric_enable = false` --> Optional. By default the metric_enable is true
* application_name --> Optional
* subsystem_name --> Optional
* logs_enable --> Enables sending logs
* source_type_logs --> The type of the logs you send to firehose
* integration_type_logs --> The integration type of the firehose delivery stream: `CloudWatch_JSON`, `WAF`, `CloudWatch_CloudTrail`, `EksFargate`, `Default`, `RawText`
* kinesis_stream_arn --> If sending logs from kinesis data stream add its arn here. In addition the next values should be: `source_type_logs=KinesisStreamAsSource` and `integration_type_logs=RawText`
* firehose_stream --> The name of the Firehose delivery stream
* coralogix_region --> The region of Coralogix account
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* enable_cloudwatch_metricstream --> the creation of a [cloudwatch metrics stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) can be disabled by setting this variable to 'false'
