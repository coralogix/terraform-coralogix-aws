# Firehose Delivery Stream with CloudWatch metrics stream with filtered metric names of selected namespaces 
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream. 
The CloudWatch metrics stream in this example includes both specific namespaces and metric names that are inserted in the list object. If the filter's list of metric_names is left empty, all metric_names are included in the namespace.

All of the namespaces are created under one metric stream, see [use metric streams](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html)


In the below example, 'AWS/EC2' namespace includes only CPUUtilization and NetworkOut metrics, while "AWS/S3" will include all metrics available:
```
coralogix-filter-metric-names:
[
    {
      namespace    = "AWS/EC2"
      metric_names = ["CPUUtilization", "NetworkOut"]
    }, 
    {
      namespace    = "AWS/S3"
      metric_names = []
    }
]
```

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* coralogix_region --> The region of Coralogix account
* privatekey --> Coralogix account logs privatekey
Since the privatekey is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_coralogix_privatekey="your-coralogix-private-key"
* include_all_namespaces --> this variable needs to be set to 'false' to disable the creation of all available cloudwatch namespaces
* include_metric_stream_filter --> List of inclusive metric filters for namespace and metric_names. For the full list of the available namespaces, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). To view available metric names of selected namespace, please see [view available metric names](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html)