# Firehose Module
Firehose module is designed to support CloudWatch metrics.

## Metrics - Usage
### Firehose Delivery Stream
Provision a firehose delivery stream for streaming metrics to Coralogix:
```
module "cloudwatch_firehose_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                = var.coralogix_firehose_stream_name
  privatekey                     = var.coralogix_privatekey
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
  firehose_stream  = var.coralogix_firehose_stream_name
  privatekey       = var.coralogix_privatekey
  coralogix_region = var.coralogix_region
}
```

### Delivering selected CloudWatch metrics namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
The metric stream includes only selected namespaces and sends the metrics to Coralogix:
When including only specific namespaces, the variable 'include_all_namespaces' needs to disabled,
and the variable 'include_metric_stream_namespaces' needs to include a list of the desired namespaces,
which are case-sensitive. please see the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). 
```
module "cloudwatch_firehose_coralogix" {
  source                           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                  = var.coralogix_firehose_stream_name
  privatekey                       = var.coralogix_privatekey
  include_all_namespaces           = var.include_all_namespaces
  include_metric_stream_namespaces = var.include_metric_stream_namespaces
  coralogix_region                 = var.coralogix_region
}
```

### Filtering selected metrics names from CloudWatch namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
For inclusive metric filters of metric names belonging to a selected namespace:

Likewise when using this to include only specific namespaces and metric names, the variable 'include_all_namespaces' needs to disabled.
The variable 'include_metric_stream_filter' can be used to send only conditional metric names belonging to a selected metric namespace. For any namespace where the metric names is empty or not specified, all metrics in that namespace is included.

Metric namespaces are also case-sensitive, please see the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). For Metric names belonging to a namespace, please see the [AWS View available metrics guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html)

```
module "cloudwatch_firehose_coralogix" {
  source                           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                  = var.coralogix_firehose_stream_name
  privatekey                       = var.coralogix_privatekey
  include_all_namespaces           = var.include_all_namespaces
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
  for_each         = toset(var.coralogix_streams)
  firehose_stream  = each.key
  privatekey       = var.coralogix_privatekey
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
if using `Json` in the firehose output format, which is configured via the `integration_type` variable,
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

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.firehose_loggroup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.firehose_logstream_backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_log_stream.firehose_logstream_dest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream) | resource |
| [aws_cloudwatch_metric_stream.cloudwatch_metric_stream_all_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [aws_cloudwatch_metric_stream.cloudwatch_metric_stream_included_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_stream) | resource |
| [aws_iam_role.firehose_to_coralogix](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.metric_streams_to_firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.firehose_to_http_metric_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.metric_streams_to_firehose_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kinesis_firehose_delivery_stream.coralogix_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_s3_bucket.firehose_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_caller_identity.current_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: us, singapore, ireland, india, stockholm [in lower-case letters] | `any` | n/a | yes |
| <a name="input_enable_cloudwatch_metricstream"></a> [enable\_cloudwatch\_metricstream](#input\_enable\_cloudwatch\_metricstream) | Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose | `bool` | `true` | no |
| <a name="input_firehose_stream"></a> [firehose\_stream](#input\_firehose\_stream) | AWS Kinesis firehose delivery stream name | `string` | n/a | yes |
| <a name="input_include_all_namespaces"></a> [include\_all\_namespaces](#input\_include\_all\_namespaces) | If set to true, the CloudWatch metric stream will include all available namespaces | `bool` | `true` | no |
| <a name="input_include_metric_stream_namespaces"></a> [include\_metric\_stream\_namespaces](#input\_include\_metric\_stream\_namespaces) | List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html | `list(string)` | `[]` | no |
| <a name="input_integration_type"></a> [integration\_type](#input\_integration\_type) | The integration type of the firehose delivery stream: 'CloudWatch\_Metrics\_JSON' or 'CloudWatch\_Metrics\_OpenTelemetry070' | `string` | `"CloudWatch_Metrics_OpenTelemetry070"` | no |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7' | `string` | `"opentelemetry0.7"` | no |
| <a name="input_privatekey"></a> [privatekey](#input\_privatekey) | Coralogix account logs private key | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Authors
Module is maintained by [Amit Mazor](https://github.com/orgs/coralogix/people/amit-mazor)
