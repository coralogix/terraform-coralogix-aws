# Firehose Delivery Stream with addtional metric statistics for Cloudwatch metric streams
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream.

The CloudWatch metrics stream in this example includes additional metric statistics both of specific namespaces, metric names, and a list of percentage values. `additional_metric_statistics_enable` is also required to be set to `true`. If `additional_metric_statistics_enable` is enabled `true` but `additional_metric_statistics` is not overwritten, then the default recommended statistics is taken.

Avalible types of the additional statistics are listed under [statistics that can be streamed](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-statistics.html) on AWS.

## Example

In the below example, four different AWS metrics are added percentile statistics to get data about the 50th to 99th percentile of telemetry. Helping to understand the median to highest utilization rates:
```
additional_metric_statistics_enable = true
additional_metric_statistics:
[
    {
      additional_statistics = ["p75", "p99"],
      metric_name           = "VolumeTotalReadTime",
      namespace             = "AWS/EBS"
    },
    {
      additional_statistics = ["p75", "p99"],
      metric_name           = "VolumeTotalWriteTime",
      namespace             = "AWS/EBS"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "Latency",
      namespace             = "AWS/ELB"
    },
    {
      additional_statistics = ["p50", "p75", "p95", "p99"],
      metric_name           = "FirstByteLatency",
      namespace             = "AWS/S3"
    },
  ]
```

## Usage

In this example you need to configure the following variables:
* firehose_stream --> The name of the Firehose delivery stream
* coralogix_region --> The region of Coralogix account
* private_key --> Coralogix account logs private_key
Since the private_key is private and we cant put it hardcoded, it can be exported instead of insert it as an input each time:
export TF_VAR_private_key="your-coralogix-private-key"
* additional_metric_statistics_enable --> Enable additional metric statistics for CloudWatch metric streams
* additional_metric_statistics --> List of additional metric statistics for namespace, metric_name and additional_statistics. For the full list of the available namespaces, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). To view available metric names of selected namespace, please see [view available metric names](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html). For the full list of the available additional statistics, please see [statistics that can be streamed](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-statistics.html)