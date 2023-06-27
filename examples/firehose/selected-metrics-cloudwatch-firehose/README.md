# Firehose Delivery Stream with CloudWatch metrics stream including specific metrics namespaces 
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream. 
The CloudWatch metrics stream in this example includes only specific namespaces that are inserted in the list.   
All of the namespaces are created under one metric stream, for example:
[](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html)
```
coralogix-metric-stream:
AWS/EC2
AWS/DynamoDB
AWS/EBS
```

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* coralogix_region --> The region of Coralogix account
* private_key --> Coralogix account logs private_key
Since the private_key is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_private_key="your-coralogix-private-key"
* include_metric_stream_namespaces --> The list of the the desired namespaces, for example: ["EC2", "DynamoDB"]. For the full list of the available namespaces and how they need to be mentioned, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)'
