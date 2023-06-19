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
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* include_all_namespaces --> this variable needs to be set to 'false' to disable the creation of all available cloudwatch namespaces
* include_metric_stream_namespaces --> List of inclusive metric filters for namespace and metric_names. For the full list of the available namespaces, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). For guide to view available metric names of namespace, please see [view available metrics](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html)'