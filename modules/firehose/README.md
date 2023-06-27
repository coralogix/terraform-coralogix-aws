# Firehose Module - Metrics And Logs
Firehose module is designed to support CloudWatch metrics.

## Logs - Usage
### Firehose Delivery Stream
Provision a firehose delivery stream for streaming logs to [Coralogix](https://coralogix.com/docs/aws-firehose/) - add this parameters to the configuration of the integration to enable to stream logs:
```
module "cloudwatch_firehose_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  logs_enable                    = true
  metric_enable                  = false
  firehose_stream                = var.coralogix_firehose_stream_name
  private_key                    = var.private_key
  coralogix_region               = var.coralogix_region
  integration_type_logs          = "Default"
  source_type_logs               = "DirectPut"
}
```

## Metrics - Usage
### Firehose Delivery Stream
Provision a firehose delivery stream for streaming metrics to Coralogix:
```
module "cloudwatch_firehose_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  metric_enable                  = true
  firehose_stream                = var.coralogix_firehose_stream_name
  private_key                    = var.private_key
  enable_cloudwatch_metricstream = false
  coralogix_region               = var.coralogix_region
}
```

### Delivering all CloudWatch metrics
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
The metric stream includes all namespaces [AWS/EC2, AWS/EBS, etc..], and sends the metrics to Coralogix:
```
module "cloudwatch_firehose_coralogix" {
  source           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  metric_enable    = true
  firehose_stream  = var.coralogix_firehose_stream_name
  private_key      = var.private_key
  coralogix_region = var.coralogix_region
}
```

### Delivering selected CloudWatch metrics by namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
The metric stream includes only selected namespaces and sends the metrics to Coralogix:
When including specific namespaces, the variable 'include_metric_stream_namespaces' needs to include a list of the desired namespaces,
which are case-sensitive. please see the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). 
```
module "cloudwatch_firehose_coralogix" {
  source                           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  metric_enable                    = true
  firehose_stream                  = var.coralogix_firehose_stream_name
  private_key                      = var.private_key
  include_metric_stream_namespaces = var.include_metric_stream_namespaces
  coralogix_region                 = var.coralogix_region
}
```

### Filtering selected metric names from included CloudWatch namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
For more granular inclusive filters of metric names belonging to an included namespace:

The variable 'include_metric_stream_filter' can be used to send only conditional metric names belonging to a selected metric namespace. For any selected namespace where the metric names list is empty or not specified, all metrics in that namespace is included.

Note: 'include_metric_stream_namespaces' and 'include_metric_stream_filter' are independent but related the same metric stream include filter and may conflict. If error or metrics do not show, check console CloudWatch -> Metrics -> Streams -> Selected Metrics table on result.

Metric namespaces are also case-sensitive, please see the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). For case-sensitive metric names belonging to a namespace, please see the [AWS View available metrics guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html)

```
module "cloudwatch_firehose_coralogix" {
  source                           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  metric_enable                    = true
  firehose_stream                  = var.coralogix_firehose_stream_name
  private_key                      = var.private_key
  include_metric_stream_filter     = var.include_metric_stream_filter
  coralogix_region                 = var.coralogix_region
}
```

Where the variable 'include_metric_stream_filter' can be set as follows:
```
variable "include_metric_stream_filter" {
  description = "List of inclusive metric filters for namespace and metric_names. Specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. If metric names is empty or not specified, the whole metric namespace is included"
  type = list(object({
    namespace    = string
    metric_names = list(string)
    })
  )
  default = [
    {
      namespace    = "AWS/EC2"
      metric_names = ["CPUUtilization", "NetworkOut"]
    },
    {
      namespace    = "AWS/S3"
      metric_names = ["BucketSizeBytes"]
    },
  ]
}
```

### Multiple Firehose Delivery Stream
Provision multiple firehose delivery streams, which can include the provisioning of CloudWatch metric stream if desired:
```
module "cloudwatch_firehose_coralogix" {
  source           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  metric_enable                  = true
  for_each         = toset(var.coralogix_streams)
  firehose_stream  = each.key
  private_key      = var.private_key
  coralogix_region = var.coralogix_region
}
```

### Examples
Examples can be found under the [examples directory](https://github.com/coralogix/terraform-coralogix-aws/blob/master/examples/firehose/selected-metrics-cloudwatch-firehose)

## Override Coralogix applicationName
The application name by default is the firehose delivery stream name, but it can be overriden by setting an environment variable called `application_name`. 

# Coralogix account region
The coralogix region variable accepts one of the following regions:
* us
* singapore
* ireland
* india
* stockholm

### All of the regions must be written with lower-case letters. 

| Region    | Metrics Endpoint
|-----------|-----------------------------------------------------------------|
| us        | `https://firehose-ingress.coralogix.us/firehose`                |
| singapore | `https://firehose-ingress.coralogixsg.com/firehose`             |
| ireland   | `https://firehose-ingress.coralogix.com/firehose`               |
| india     | `https://firehose-ingress.app.coralogix.in/firehose`            |
| stockholm | `https://firehose-ingress.coralogix.eu2.coralogix.com/firehose` |

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
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: us, singapore, ireland, india, stockholm [in lower-case letters] | `any` | n/a | yes |
| <a name="input_enable_cloudwatch_metricstream"></a> [enable\_cloudwatch\_metricstream](#input\_enable\_cloudwatch\_metricstream) | Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose | `bool` | `true` | no |
| <a name="input_firehose_stream"></a> [firehose\_stream](#input\_firehose\_stream) | AWS Kinesis firehose delivery stream name | `string` | n/a | yes |
| <a name="input_include_metric_stream_namespaces"></a> [include\_metric\_stream\_namespaces](#input\_include\_metric\_stream\_namespaces) | List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html | `list(string)` | `[]` | no |
| <a name="include_metric_stream_filter"></a> [include\_metric\_stream\_filter](#input\_include\_metric\_stream\_filter) | Guide to view specific metric names of namespaces, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html | `list(object({namespace=string, metric_names=list(string)})` | `[]` | no |
| <a name="input_integration_type_metrics"></a> [integration\_type](#input\_integration\_type) | The integration type of the firehose delivery stream: 'CloudWatch\_Metrics\_JSON' or 'CloudWatch\_Metrics\_OpenTelemetry070' | `string` | `"CloudWatch_Metrics_OpenTelemetry070"` | no |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7' | `string` | `"opentelemetry0.7"` | no |
| <a name="input_private_key"></a> [private_key](#input\_private_key) | Coralogix account logs private key | `any` | n/a | yes |
| <a name="input_metric_enable"></a> [metric_enable](#input\_metric_enable) | Enble sending metrics to Coralogix | `bool` | `true` | no |
| <a name="input_application_name"></a> [application_name](#input\_application_name) | The name of your application in Coralogix | `string` | n/a | no |
| <a name="input_subsystem_name"></a> [subsystem_name](#input\_subsystem_name) | The subsystem name of your application in Coralogix | `string` | n/a | no |
| <a name="input_user_supplied_tags"></a> [user_supplied_tags](#input\_user_supplied_tags) | Tags supplied by the user to populate to all generated resources | `map(string)` | n/a | no |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch_retention_days](#input\_cloudwatch_retention_days) | Days of retention in Cloudwatch retention days | `number` | n/a | no |
| <a name="input_coralogix_firehose_custom_endpoint"></a> [coralogix_firehose_custom_endpoint](#input\_coralogix_firehose_custom_endpoint) | Custom endpoint for Coralogix firehose integration endpoint  (https://firehose-ingress.private.coralogix.net:8443/firehose) | `string` | `null` | no |
| <a name="input_logs_enable"></a> [logs_enable](#input\_logs_enable) | Enble sending logs to Coralogix | `bool` | `false` | no |
| <a name="input_source_type_logs"></a> [source_type_logs](#input\_source_type_logs) | The source_type of kinesis firehose: KinesisStreamAsSource or DirectPut | `string` | `DirectPut` | no |
| <a name="input_kinesis_stream_arn"></a> [kinesis_stream_arn](#input\_kinesis_stream_arn) | The kinesis stream name for the logs - used in kinesis stream as a source | `string` | `""` | no |
| <a name="input_kinesis_stream_arn"></a> [kinesis_stream_arn](#input\_integration_type_logs) | The integration type of the firehose delivery stream: 'CloudWatch_JSON', 'WAF', 'CloudWatch_CloudTrail', 'EksFargate', 'Default', 'RawText' | `string` | `Default` | no |
| <a name="input_dynamic_metadata_logs"></a> [dynamic_metadata_logs](#input\_dynamic_metadata_logs) | Dynamic values search for specific fields in the logs to populate the fields | `bool` | `false` | no |


## Outputs

No outputs.
<!-- END_TF_DOCS -->
