# Firehose Delivery Stream with the different metrics configurations
Configuration in this directory creates a firehose delivery stream, and a CloudWatch metrics stream.

The CloudWatch metrics stream in this example includes both specific namespaces and metric names that are inserted in the list object. This is done either through the `include_metric_stream_namespaces` param to list selected namespaces (and all metric_names associated) or a more granular `include_metric_stream_filter` for selected namespaces and metric_names. Note: If a filter's list for metric_names is empty`[]`, all related metric_names to the namespace are exported.

In the below example, for `include_metric_stream_namespaces`, all metric_names from namespaces `AWS/Lambda` and `AWS/DynamoDB` is exporterd. However in `include_metric_stream_filter`, the `AWS/EC2` namespace includes only `CPUUtilization` and `NetworkOut` metrics, while `AWS/S3` will include all metrics_names.

```
include_metric_stream_namespaces = ["AWS/Lambda", "AWS/DynamoDB"]

include_metric_stream_filter = [
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

# Firehose Delivery Stream with additional metric statistics

Also, `additional_metric_statistics` provide a means to configure additional statistics to a given metric. This is done by specifying the `additional_statistics` list of additional metrics and the `metric_name` and `namespace` of the metric. Read [Use metric streams](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) for more infomation.

Depending on the `output_format` variable configured (default `opentelemetry0.7`). The `json` format would support streaming of statistics provided by CloudWatch and the `opentelemetry0.7` (default) supports streaming percentile statistics (p99 etc.). Read [Statistics that can be streamed](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-statistics.html) for more information on avalible statistics and [statistical definitions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html) for an explaintation.

In the below example, for `additional_metric_statistics`, the `VolumeTotalReadTime` and `VolumeTotalWriteTime` metrics from the `AWS/EBS` namespace will be streamed with `p75` and `p99` statistics. The `Latency` and `FirstByteLatency` metrics from the `AWS/ELB` and `AWS/S3` namespaces will be streamed with `p50`, `p75`, `p95` and `p99` statistics. And because `output_format` of `opentelemetry0.7` is configured, only percentile values are supported.

```
output_format = "opentelemetry0.7"

additional_metric_statistics_enable = true
additional_metric_statistics = [
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
* include_metric_stream_namespaces --> The list of the the desired namespaces, for example: ["EC2", "DynamoDB"]. For the full list of the available namespaces and how they need to be mentioned, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)'
* include_metric_stream_filter --> List of inclusive metric filters for namespace and metric_names. For the full list of the available namespaces, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). To view available metric names of selected namespace, please see [view available metric names](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html)
* additional_metric_statistics_enable --> Enable additional metric statistics for CloudWatch metric streams
* additional_metric_statistics --> List of additional metric statistics for namespace, metric_name and additional_statistics. For the full list of the available namespaces, please see [namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). To view available metric names of selected namespace, please see [view available metric names](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html). For the full list of the available additional statistics, please see [statistics that can be streamed](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-statistics.html)