# Firehose Module

## Usage
Provision an AWS firehose delivery stream for streaming metrics to Coralogix:
```
module "cloudwatch_firehose_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream                = var.coralogix_firehose_stream_name
  privatekey                     = var.coralogix_privatekey
  enable_cloudwatch_metricstream = false
  coralogix_region               = var.coralogix_region
}
```

Provision the firehose delivery stream with CloudWatch metric stream that includes all namespaces [AWS/EC2, AWS/EBS, etc..]
to send metrics from CloudWatch to Coralogix:
```
module "cloudwatch_firehose_coralogix" {
  source           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  firehose_stream  = var.coralogix_firehose_stream_name
  privatekey       = var.coralogix_privatekey
  coralogix_region = var.coralogix_region
}
```

Provision the firehose delivery stream with CloudWatch metric stream that includes only selected namespaces [AWS/EC2, AWS/EBS, etc..]
to send metrics from CloudWatch to Coralogix:
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
### note:
When Using the variable 'include_metric_stream_namespaces' - the chosen namespaces are case-sensitive, therefore they must appear exactly like they appear in AWS, please see the [AWS namespaces list]: 
(https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)

Provision multiple firehose delivery streams, which can include the provisioning of CloudWatch metric stream if enabled:
```
module "cloudwatch_firehose_coralogix" {
  source           = "github.com/coralogix/terraform-coralogix-aws//modules/firehose"
  for_each         = toset(var.coralogix_streams)
  firehose_stream  = each.key
  privatekey       = var.coralogix_privatekey
  coralogix_region = var.coralogix_region
}
```

# Coralogix account region
The coralogix region variable accepts one of the following:
* us
* singapore
* ireland
* india
* stockholm

# Metrics Output Format
Coralogix suppots both 'JSON' format and 'OpenTelemtry' format. 
The default format configured here is 'OpenTelemtry'. 
#### Note
if using 'Json' in the firehose output format, which is configured via the 'integration_type' variable,
then the CloudWatch metric stream must be configured with the same format, configured via the 'output_format' variable.



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.17.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.17.1 |

## Modules

No modules.

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
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: us, singapore, ireland, india, stockholm [in lower-case letterד] | `any` | n/a | yes |
| <a name="input_enable_cloudwatch_metricstream"></a> [enable\_cloudwatch\_metricstream](#input\_enable\_cloudwatch\_metricstream) | Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose | `bool` | `true` | no |
| <a name="input_endpoint_url"></a> [endpoint\_url](#input\_endpoint\_url) | Firehose Coralogix endpoint | `map(any)` | <pre>{<br>  "india": {<br>    "url": "https://firehose-ingress.coralogix.in/firehose"<br>  },<br>  "ireland": {<br>    "url": "https://firehose-ingress.coralogix.com/firehose"<br>  },<br>  "singapore": {<br>    "url": "https://firehose-ingress.coralogixsg.com/firehose"<br>  },<br>  "stockholm": {<br>    "url": "https://firehose-ingress.eu2.coralogix.com/firehose"<br>  },<br>  "us": {<br>    "url": "https://firehose-ingress.coralogix.us/firehose"<br>  }<br>}</pre> | no |
| <a name="input_firehose_stream"></a> [firehose\_stream](#input\_firehose\_stream) | AWS Kinesis firehose delivery stream name | `string` | n/a | yes |
| <a name="input_include_all_namespaces"></a> [include\_all\_namespaces](#input\_include\_all\_namespaces) | If set to true, the CloudWatch metric stream will include all available namespaces | `bool` | `true` | no |
| <a name="input_include_metric_stream_namespaces"></a> [include\_metric\_stream\_namespaces](#input\_include\_metric\_stream\_namespaces) | List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html | `list(string)` | `[]` | no |
| <a name="input_integration_type"></a> [integration\_type](#input\_integration\_type) | The integration type of the firehose delivery stream: 'CloudWatch\_Metrics\_JSON' or 'CloudWatch\_Metrics\_OpenTelemetry070' | `string` | `"CloudWatch_Metrics_OpenTelemetry070"` | no |
| <a name="input_output_format"></a> [output\_format](#input\_output\_format) | The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7' | `string` | `"opentelemetry0.7"` | no |
| <a name="input_privatekey"></a> [privatekey](#input\_privatekey) | Coralogix account logs private key | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->