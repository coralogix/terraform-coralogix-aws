# Firehose Metrics Module

Firehose Metrics module is designed to support AWS Firehose Metrics integration with Coralogix. Leveraging AWS CloudWatch Metrics Stream.

## Metrics - Usage

### Delivering all CloudWatch metrics
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) to stream metrics to [Coralogix](https://coralogix.com/docs/amazon-kinesis-data-firehose-metrics/).

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source           = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream  = var.coralogix_firehose_stream_name
  private_key      = var.private_key
  coralogix_region = var.coralogix_region
}
```

By default, the metric stream includes all namespaces [AWS/EC2, AWS/EBS, etc..] and metric names.


### Delivering selected CloudWatch metrics by namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
The metric stream includes only selected namespaces and sends the metrics to Coralogix:
When including specific namespaces, the variable 'include_metric_stream_namespaces' needs to include a list of the desired namespaces,
which are case-sensitive. please see the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). 

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source                           = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream                  = var.coralogix_firehose_stream_name
  private_key                      = var.private_key
  include_metric_stream_namespaces = var.include_metric_stream_namespaces
  coralogix_region                 = var.coralogix_region
}
```

### Filtering selected metric names from namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
For more granular inclusive filters of metric names belonging to an included namespace:

The variable `include_metric_stream_filter` can be used to send only conditional metric names belonging to a selected metric namespace. For any selected namespace where the metric names list is empty or not specified, all metrics in that namespace is included.

**Note**: `include_metric_stream_namespaces` and `include_metric_stream_filter` are independent but related the same metric stream include filter and may conflict. If error or metrics do not show, check console _CloudWatch_ -> _Metrics_ -> _Streams_ -> _Selected Metrics_ table on result.

Metric namespaces are also case-sensitive, please see the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). For case-sensitive metric names belonging to a namespace, please see the [AWS View available metrics guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html)

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source                           = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream                  = var.coralogix_firehose_stream_name
  private_key                      = var.private_key
  
  # If metric names is empty or not specified, the whole metric namespace is included
  include_metric_stream_filter     = [
    {
      namespace    = "AWS/EC2"
      metric_names = ["CPUUtilization", "NetworkOut"]
    },
    {
      namespace    = "AWS/S3"
      metric_names = ["BucketSizeBytes"]
    },
  ]
  coralogix_region                 = var.coralogix_region
}
```

### Additional Statistics
Also, `additional_metric_statistics` provide a means to configure additional statistics to a given metric. This is done by specifying the metric_name and namespace and corresponding list of additional statistics. Read [metric streams](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) for more infomation. Set `additional_metric_statistics_enable` to true to enable this featurem, 

Depending on the `output_format` variable configured (default opentelemetry0.7). The `json` format would support streaming of statistics provided by CloudWatch and the `opentelemetry0.7` (default) supports streaming percentile statistics (p99.). 

If `additional_metric_statistics` is not configured but is enabled `true`, the module's default configuration of recommended metric and statistics is used which is configured to the `p50`, `p75`, `p95` and `p99` percentiles.

In the below example, `additional_metric_statistics` is enabled and the default configured metrics, namespaces and additional statistics percentiles are used. Note: as `output_format` of `opentelemetry0.7` is configured, only percentile values are supported.

```terraform
output_format = "opentelemetry0.7"

additional_metric_statistics_enable = true
additional_metric_statistics = [
  {
    additional_statistics = ["p50", "p75", "p95", "p99"],
    metric_name           = "VolumeTotalReadTime",
    namespace             = "AWS/EBS"
  },
  {
    additional_statistics = ["p50", "p75", "p95", "p99"],
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
    metric_name           = "Duration",
    namespace             = "AWS/ELB"
  },
  {
    additional_statistics = ["p50", "p75", "p95", "p99"],
    metric_name           = "PostRuntimeExtensionsDuration",
    namespace             = "AWS/Lambda"
  },
  {
    additional_statistics = ["p50", "p75", "p95", "p99"],
    metric_name           = "FirstByteLatency",
    namespace             = "AWS/S3"
  },
  {
    additional_statistics = ["p50", "p75", "p95", "p99"],
    metric_name           = "TotalRequestLatency",
    namespace             = "AWS/S3"
  }
]
```

### Removal of CloudWatch Metric Streams Lambda transformation
By default, a [Coralogix Lambda Transformation Function](https://github.com/coralogix/cloudwatch-metric-streams-lambda-transformation) has been added to the [Kinesis Firehose Data Transformation](https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html) as a `processing_configuration`. This is done, to enrich the metrics from CloudWatch Metric Streams with AWS resource tags. The optional lambda function is deployed as part of the module, and can be removed by setting the variable `lambda_processor_enable` to `false`.

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source                           = "coralogix/aws/coralogix//modules/firehose-metrics"
  lambda_processor_enable          = false
  firehose_stream                  = var.coralogix_firehose_stream_name
  private_key                      = var.private_key
  coralogix_region                 = var.coralogix_region
}
```

Read more about the following:

- [Statistics that can be streamed](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-statistics.html)
- [Metric streams output formats](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-formats.html) 
- [Statistical definitions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html)


### Examples
Examples can be found under the [firehose-metrics examples directory](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-metrics)

## Override Coralogix applicationName and subsystemName
The application name and subsystem name by default is the firehose delivery stream arn and name, but it can be overriden by setting an environment variable called `application_name` and `subsystem_name`. 

# Coralogix account region
The coralogix region variable accepts one of the following regions:
* Europe
* Europe2
* India
* Singapore
* US
* US2

### Coralogix Regions & Description. 

| Region    | Domain                 |  Endpoint                                       |
|-----------|------------------------|---------------------------------------------------------|
| Europe    | `coralogix.com`        | `https://firehose-ingress.coralogix.com/firehose`       |
| Europe2   | `eu2.coralogix.com`    | `https://firehose-ingress.eu2.coralogix.com/firehose`   |
| India     | `coralogix.in`         | `https://firehose-ingress.app.coralogix.in/firehose`    |
| Singapore | `coralogixsg.com`      | `https://firehose-ingress.coralogixsg.com/firehose`     |
| US        | `coralogix.us`         | `https://firehose-ingress.coralogix.us/firehose`        |
| US2       | `cx498.coralogix.com`  | `https://firehose-ingress.cx498.coralogix.com/firehose` |

### Custom endpoints
It is possible to pass a custom firehose ingress endpoint with by using the `coralogix_firehose_custom_endpoint` variable.

# Metrics Output Format
Coralogix suppots both `JSON` format and `OpenTelemtry` format. 
The default format configured here is `OpenTelemtry`. 
if using `Json` in the firehose output format, which is configured via the `integration_type_metrics` variable,
then the CloudWatch metric stream must be configured with the same format, configured via the `output_format` variable.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.17.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.17.1 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: Europe, Europe2, India, Singapore, US, US2 [exact] | `any` | n/a | yes |
| <a name="input_private_key"></a> [private_key](#input\_private_key) | Coralogix account logs private key | `any` | n/a | yes |
| <a name="input_firehose_stream"></a> [firehose\_stream](#input\_firehose\_stream) | AWS Kinesis firehose delivery stream name | `string` | n/a | yes |
| <a name="input_application_name"></a> [application_name](#input\_application_name) | The name of your application in Coralogix | `string` | n/a | yes |
| <a name="input_subsystem_name"></a> [subsystem_name](#input\_subsystem_name) | The subsystem name of your application in Coralogix | `string` | n/a | yes |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch\_retention\_days](#input\_cloudwatch_retention_days) | Days of retention in Cloudwatch retention days | `number` | n/a | no |
| <a name="input_custom_domain"></a> [custom_domain](#input\_custom_domain) | Custom domain for Coralogix firehose integration endpoint (private.coralogix.net:8443) | `string` | `null` | no |
| <a name="input_integration_type_metrics"></a> [integration\_type\_metrics](#input\_integration\_type\_metrics) | The integration type of the firehose delivery stream: `CloudWatch_Metrics_OpenTelemetry070` or `CloudWatch_Metrics_OpenTelemetry070_WithAggregations`. For `_WithAggregations` choice, additional aggregations here are `_min`, `_max`, `_avg` recorded as gauges. See https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-formats-opentelemetry-translation.html | `string` | `"CloudWatch_Metrics_OpenTelemetry070_WithAggregations"` | no |
| <a name="input_enable_cloudwatch_metricstream"></a> [enable\_cloudwatch\_metricstream](#input\_enable\_cloudwatch\_metricstream) | Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose | `bool` | `true` | no |
| <a name="input_s3_backup_custom_name"></a> [s3_backup_custom_name](#input\_s3_backup_custom_name) | Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup-metrics-{random_string}' will be used. | `string` | n/a | no |
| <a name="input_existing_s3_backup"></a> [existing_s3_backup](#input\_input_existing_s3_backup) | Use an existing S3 bucket to use as a backup bucket. | `string` | n/a | no |
| <a name="input_lambda_processor_enable"></a> [lambda_processor_enable](#input\_lambda_processor_enable) | Enable the lambda processor function. Set to false to remove the lambda and all associated resources. | `bool` | `true` | no |

| <a name="input_lambda_processor_iam_custom_name"></a> [lambda_processor_iam_custom_name](#input\_lambda_processor_iam_custom_name) | Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup-metrics-{random_string}' will be used. | `string` | n/a | no |
lambda_processor_iam_custom_name


| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7' | `string` | `"opentelemetry0.7"` | no |
| <a name="input_include_metric_stream_namespaces"></a> [include\_metric\_stream\_namespaces](#input\_include\_metric\_stream\_namespaces) | List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html | `list(string)` | `[]` | no |
| <a name="input_include_metric_stream_filter"></a> [include\_metric\_stream\_filter](#input\_include\_metric\_stream\_filter) | Guide to view specific metric names of namespaces, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html | `list(object({namespace=string, metric_names=list(string)})` | `[]` | no |
| <a name="input_additional_metric_statistics_enable"></a> [input\_additional\_metric\_statistics\_enable](#input\_additional\_metric\_statistics\_enable) | To enable the inclusion of additional statistics to the streaming metrics | `bool` | `true` | no |
| <a name="input_additional_metric_statistics"></a> [input\_additional\_metric\_statistics](#input\_additional\_metric\_statistics) | For each entry, specify one or more metrics (metric_name and namespace) and the list of additional statistics to stream for those metrics. Each configuration of metric name and namespace can have a list of additional_statistics included into the AWS CloudWatch Metric Stream. | `list(object({additional_statistics=list(string), metric_name=string, namespace=string}))` | See variables.tf | no |
| <a name="input_user_supplied_tags"></a> [user_supplied_tags](#input\_user_supplied_tags) | Tags supplied by the user to populate to all generated resources | `map(string)` | n/a | no |
| <a name="input_override_default_tags"></a> [override_default_tags](#input\_override_default_tags) | Override and remove the default tags by setting to true | `bool` | `false` | no |


## Inputs - Custom Resource Naming
If there are conflicts with existing resources, the following variables can be used to customize the names of the resources created by this module.
 
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_metric_stream_custom_name"></a> [cloudwatch_metric_stream_custom_name](#input\_cloudwatch_metric_stream_custom_name) | Set the name of the CloudWatch metric stream, otherwise variable 'firehose_stream' will be used | `string` | `null` | no |
| <a name="input_s3_backup_custom_name"></a> [s3_backup_custom_name](#input\_s3_backup_custom_name) | Set the name of the S3 backup bucket, otherwise variable '{firehose_stream}-backup-metrics' will be used | `string` | `null` | no |
| <a name="input_lambda_processor_custom_name"></a> [lambda_processor_custom_name](#input\_lambda_processor_custom_name) | Set the name of the lambda processor function, otherwise variable '{firehose_stream}-metrics-tags-processor' will be used | `string` | `null` | no |

## Coralgoix regions

| Coralogix region | AWS Region | Coralogix Domain |
|------------------|------------|------------------|
| `Europe` | `eu-west-1` | coralogix.com |
| `Europe2` | `eu-north-1` | eu2.coralogix.com |
| `India` | `ap-south-1` | coralogix.in |
| `Singapore` | `ap-southeast-1` | coralogixsg.com |
| `US` | `us-east-2` | coralogix.us |
| `US2` | `us-west-2` | cx498.coralogix.com |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
