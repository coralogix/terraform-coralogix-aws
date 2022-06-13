# Firehose Delivery Stream with CloudWatch metrics stream including specific metrics namespaces 
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream. 
The CloudWatch metrics stream in this example includes only specific namespaces that are inserted in the list.   
All of the namespaces are created under one metric stream, for example:
```
coralogix-metric-stream:
AWS/EC2
AWS/DynamoDB
AWS/EBS
```

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* endpoint_url --> The url of the Coralogix endpoint, see [Coralogix Endpoints](https://github.com/coralogix/terraform-coralogix-aws/blob/master/modules/firehose/README.md)
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* include_all_namespaces --> this variable needs to be set to 'false' to disable the creation of all available cloudwatch namespaces
* include_metric_stream_namespaces --> The list of the the desired namespaces, for example: ["EC2", "DynamoDB"]. For the full list of the available namespaces and how they need to be mentioned, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)'