# Firehose Metrics Module

Firehose Metrics module is designed to support AWS Firehose Metrics integration with Coralogix. Leveraging AWS CloudWatch Metrics Stream.

## Metrics - Usage

### Delivering all CloudWatch metrics
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) to stream metrics to [Coralogix](https://coralogix.com/docs/amazon-kinesis-data-firehose-metrics/).

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source           = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream  = var.coralogix_firehose_stream_name
  api_key          = var.api_key
  coralogix_region = var.coralogix_region
}
```

### Secrets Manager API key

Optionally pass `api_key_secret_arn` instead of `api_key` so Firehose fetches the key at runtime via `SecretsManagerConfiguration`. The secret value must be JSON: `{"api_key": "..."}`. Rotating the secret then takes effect without a Terraform apply. If the secret is encrypted with a customer managed KMS key, also set `api_key_secret_kms_key_arn`. When the module creates the Firehose IAM role, it grants `secretsmanager:GetSecretValue` (and `kms:Decrypt` when a CMK ARN is set). If you pass `existing_firehose_iam`, that role must already allow those actions.

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source             = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream    = var.coralogix_firehose_stream_name
  api_key_secret_arn = var.api_key_secret_arn
  coralogix_region   = var.coralogix_region
}
```

By default, the metric stream includes all namespaces [AWS/EC2, AWS/EBS, etc..] and metric names.


### Delivering selected CloudWatch metrics by namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
The metric stream includes only selected namespaces and sends the metrics to Coralogix:
When including specific namespaces, the variable 'include_metric_stream_namespaces' needs to include a list of the desired namespaces,
which are case-sensitive. See the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). 

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source                           = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream                  = var.coralogix_firehose_stream_name
  api_key                          = var.api_key
  include_metric_stream_namespaces = var.include_metric_stream_namespaces
  coralogix_region                 = var.coralogix_region
}
```

### Filtering selected metric names from namespaces
Provision a firehose delivery stream with [CloudWatch metric stream](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html).
For more granular inclusive filters of metric names belonging to an included namespace:

The variable `include_metric_stream_filter` can be used to send only conditional metric names belonging to a selected metric namespace. For any selected namespace where the metric names list is empty or not specified, all metrics in that namespace are included.

**Note**: `include_metric_stream_namespaces` and `include_metric_stream_filter` are independent but related the same metric stream include filter and may conflict. If you see errors or metrics don't appear, verify your selections in the CloudWatch console under **Metrics** then **Streams** then **Selected Metrics**.

Metric namespaces are also case-sensitive. See the [AWS namespaces list](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html). For case-sensitive metric names belonging to a namespace, see the [AWS View available metrics guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/viewing_metrics_with_cloudwatch.html).

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source                           = "coralogix/aws/coralogix//modules/firehose-metrics"
  firehose_stream                  = var.coralogix_firehose_stream_name
  api_key                          = var.api_key
  
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
Also, `additional_metric_statistics` provide a means to configure additional statistics to a given metric. This is done by specifying the metric_name and namespace and corresponding list of additional statistics. Read [metric streams](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-Metric-Streams.html) for more information. Set `additional_metric_statistics_enable` to true to enable this feature.

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

### Cross-account Tag Enrichment (OAM)

When using OAM linked accounts, enable Lambda cross-account tag enrichment to fetch tags from source accounts:

```terraform
# Enable cross-account tag enrichment
cross_account_enabled = true

# Map each source account ID to the role to assume in that account
cross_account_roles = {
  "123456789012" = "arn:aws:iam::123456789012:role/CoralogixMetricsReader"
}

```

Required permissions:
- Monitoring account Lambda role must allow `sts:AssumeRole` on each role in `cross_account_roles`.
- Each linked account role trust policy must allow the monitoring account Lambda processor role to assume it.
- Linked account role policy should include at least `tag:GetResources` and service-specific read actions used for resource discovery.

### Derived Labels

Add a label copied from existing resource tags. Each rule sets `target` from the first tag in `sources` that exists, isn't empty and isn't in `exclude_values` (case-insensitive). Requires `lambda_processor_enable` (default `true`) and Lambda processor v0.1.16 or later.

```terraform
derived_labels = [
  { target = "cost_center", sources = ["CostCenter", "Department"], exclude_values = ["none"] },
]
```

#### Dropping data points

Set `drop_values` on a rule to drop data points where any final label with the `target` key matches one of the values (case-insensitive), before they reach Coralogix:

```terraform
derived_labels = [
  { target = "tenant", sources = ["Solution", "Environment"], exclude_values = ["dev"], drop_values = ["tenant-a", "tenant-b"] },
]
```

Requires processor v0.1.17 or later; the default `lambda_processor_version` (0.1.18, or 0.1.19 in GovCloud) supports it. If an existing deployment runs an older processor, first apply this module version with your current `derived_labels`, then add `drop_values` in a separate apply: code and configuration aren't updated atomically, so the old code could receive `drop_values` and forward the data. Older processors forward data without filtering: v0.1.16 rejects the entire `DERIVED_LABELS` configuration when this field is present, which also disables derived labels, and v0.1.15 and earlier ignore `DERIVED_LABELS`. Filtering uses cached resource tags, so until the cache refreshes (`FILE_CACHE_EXPIRATION` Lambda environment variable, default one hour) new resources and tag changes are filtered using stale or missing labels, which can forward or drop data incorrectly. All Lambda environment variables together are limited to 4 KB ([AWS limit](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html)), so a large `drop_values` list can fail the apply. See [Dropping data points](https://github.com/coralogix/cloudwatch-metric-streams-lambda-transformation#dropping-data-points) for matching rules, S3 backup behaviour and limitations.

The Lambda processor is pinned with `lambda_processor_version` (default `0.1.18`; `0.1.19` in GovCloud), which deploys the write-once `firehose-metrics-transformer-<version>.zip`. To upgrade, set a newer [release](https://github.com/coralogix/cloudwatch-metric-streams-lambda-transformation/releases) and apply; the function code is updated in place:

```hcl
lambda_processor_version = "0.1.18"
```

### Removal of CloudWatch Metric Streams Lambda transformation
By default, a [Coralogix Lambda Transformation Function](https://github.com/coralogix/cloudwatch-metric-streams-lambda-transformation) has been added to the [Kinesis Firehose Data Transformation](https://docs.aws.amazon.com/firehose/latest/dev/data-transformation.html) as a `processing_configuration`. This is done, to enrich the metrics from CloudWatch Metric Streams with AWS resource tags. The optional lambda function is deployed as part of the module, and can be removed by setting the variable `lambda_processor_enable` to `false`.

```terraform
module "cloudwatch_firehose_metrics_coralogix" {
  source                           = "coralogix/aws/coralogix//modules/firehose-metrics"
  lambda_processor_enable          = false
  firehose_stream                  = var.coralogix_firehose_stream_name
  api_key                          = var.api_key
  coralogix_region                 = var.coralogix_region
}
```

Read more about the following:

- [Statistics that can be streamed](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-statistics.html)
- [Metric streams output formats](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch-metric-streams-formats.html) 
- [Statistical definitions](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Statistics-definitions.html)


### Examples
Examples can be found under the [firehose-metrics examples directory](https://github.com/coralogix/terraform-coralogix-aws/tree/master/examples/firehose-metrics)

## Override Coralogix `applicationName` and `subsystemName`
The application name and subsystem name by default is the firehose delivery stream arn and name, but it can be overridden by setting the `application_name` and `subsystem_name` variables.

## Coralogix account region
The Coralogix region variable accepts one of the following regions:
* EU1
* EU2
* AP1
* AP2
* AP3
* US1
* US2
* US3

### Coralogix regions and endpoints

| Region | Domain | Endpoint |
|--------|--------|----------|
| EU1 | `eu1.coralogix.com` | `https://ingress.eu1.coralogix.com/aws/firehose` |
| EU2 | `eu2.coralogix.com` | `https://ingress.eu2.coralogix.com/aws/firehose` |
| AP1 | `ap1.coralogix.com` | `https://ingress.ap1.coralogix.com/aws/firehose` |
| AP2 | `ap2.coralogix.com` | `https://ingress.ap2.coralogix.com/aws/firehose` |
| AP3 | `ap3.coralogix.com` | `https://ingress.ap3.coralogix.com/aws/firehose` |
| US1 | `us1.coralogix.com` | `https://ingress.us1.coralogix.com/aws/firehose` |
| US2 | `us2.coralogix.com` | `https://ingress.us2.coralogix.com/aws/firehose` |
| US3 | `us3.coralogix.com` | `https://ingress.us3.coralogix.com/aws/firehose` |

### Custom endpoints
To use a custom domain, set the `custom_domain` variable (e.g. `cust.coralogix-123.net:8443`). The endpoint becomes `https://ingress.<custom_domain>/aws/firehose`. This does not work for PrivateLink.

## Metrics output format
The CloudWatch metric stream format is set with `output_format` (`opentelemetry0.7`, the default, or `json`). The Firehose integration type is set with `integration_type_metrics`: `CloudWatch_Metrics_OpenTelemetry070_WithAggregations` (default) or `CloudWatch_Metrics_OpenTelemetry070`. Both integration types expect OpenTelemetry 0.7, so keep `output_format` at `opentelemetry0.7`.


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_coralogix_region"></a> [coralogix\_region](variables.tf#L1) | Coralogix account region: EU1, EU2, AP1, AP2, AP3, US1, US2, US3 | `string` | n/a | yes |
| <a name="input_api_key"></a> [api\_key](variables.tf#L10) | Coralogix account API key. Ignored when api\_key\_secret\_arn is set. Required unless api\_key\_secret\_arn is provided. | `string` | `null` | no |
| <a name="input_api_key_secret_arn"></a> [api\_key\_secret\_arn](variables.tf#L22) | ARN of a Secrets Manager secret holding the Coralogix API key as JSON, {"api\_key": "..."}.<br/>When set, Firehose reads the key at runtime and api\_key is ignored, so rotating the secret<br/>takes effect without a Terraform apply. This must be a separate secret from any plaintext<br/>value used with api\_key. Must be in the same region as the delivery stream. | `string` | `null` | no |
| <a name="input_api_key_secret_kms_key_arn"></a> [api\_key\_secret\_kms\_key\_arn](variables.tf#L33) | Optional ARN of the KMS key used to encrypt the Secrets Manager secret. Required only if the secret uses a customer managed key (CMK). | `string` | `null` | no |
| <a name="input_firehose_stream"></a> [firehose\_stream](variables.tf#L44) | AWS Kinesis firehose delivery stream name | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](variables.tf#L49) | The name of your application in Coralogix | `string` | `null` | no |
| <a name="input_subsystem_name"></a> [subsystem\_name](variables.tf#L55) | The subsystem name of your application in Coralogix | `string` | `null` | no |
| <a name="input_cloudwatch_retention_days"></a> [cloudwatch\_retention\_days](variables.tf#L61) | Days of retention in Cloudwatch retention days | `number` | `1` | no |
| <a name="input_custom_domain"></a> [custom\_domain](variables.tf#L67) | Custom domain for Coralogix firehose integration endpoints, does not work for privatelink (e.g. cust.coralogix-123.net:8443 for https://ingress.cust.coralogix-123.net:8443/aws/firehose) | `string` | `null` | no |
| <a name="input_integration_type_metrics"></a> [integration\_type\_metrics](variables.tf#L73) | The integration type of the firehose delivery stream: 'CloudWatch\_Metrics\_OpenTelemetry070' or 'CloudWatch\_Metrics\_OpenTelemetry070\_WithAggregations' | `string` | `"CloudWatch_Metrics_OpenTelemetry070_WithAggregations"` | no |
| <a name="input_output_format"></a> [output\_format](variables.tf#L79) | The output format of the cloudwatch metric stream: 'json' or 'opentelemetry0.7' | `string` | `"opentelemetry0.7"` | no |
| <a name="input_enable_cloudwatch_metricstream"></a> [enable\_cloudwatch\_metricstream](variables.tf#L85) | Should be true if you want to create a new Cloud Watch metric stream and attach it to Firehose | `bool` | `true` | no |
| <a name="input_cloudwatch_metric_stream_custom_name"></a> [cloudwatch\_metric\_stream\_custom\_name](variables.tf#L91) | Set the name of the CloudWatch metric stream, otherwise variable '{firehose\_stream}-cw' will be used | `string` | `null` | no |
| <a name="input_include_metric_stream_namespaces"></a> [include\_metric\_stream\_namespaces](variables.tf#L97) | List of specific namespaces to include in the CloudWatch metric stream, see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html | `list(string)` | `[]` | no |
| <a name="input_include_metric_stream_filter"></a> [include\_metric\_stream\_filter](variables.tf#L103) | List of inclusive metric filters for namespace and metric\_names. Specify this parameter, the stream sends only the conditional metric names from the metric namespaces that you specify here. If metric names is empty or not specified, the whole metric namespace is included | <pre>list(object({<br/>    namespace    = string<br/>    metric_names = list(string)<br/>    })<br/>  )</pre> | `[]` | no |
| <a name="input_include_linked_accounts_metrics"></a> [include\_linked\_accounts\_metrics](variables.tf#L113) | include\_linked\_accounts\_metrics (Optional) If you are creating a metric stream in a monitoring account, specify true to include metrics from source accounts that are linked to this monitoring account, in the metric stream. The default is false. | `bool` | `false` | no |
| <a name="input_additional_metric_statistics_enable"></a> [additional\_metric\_statistics\_enable](variables.tf#L119) | To enable the inclusion of additional statistics to the streaming metrics | `bool` | `false` | no |
| <a name="input_additional_metric_statistics"></a> [additional\_metric\_statistics](variables.tf#L125) | For each entry, specify one or more metrics (metric\_name and namespace) and the list of additional statistics to stream for those metrics. Each configuration of metric name and namespace can have a list of additional\_statistics included into the AWS CloudWatch Metric Stream | <pre>list(object({<br/>    additional_statistics = list(string)<br/>    metric_name           = string<br/>    namespace             = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "VolumeTotalReadTime",<br/>    "namespace": "AWS/EBS"<br/>  },<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "VolumeTotalWriteTime",<br/>    "namespace": "AWS/EBS"<br/>  },<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "Latency",<br/>    "namespace": "AWS/ELB"<br/>  },<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "Duration",<br/>    "namespace": "AWS/ELB"<br/>  },<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "PostRuntimeExtensionsDuration",<br/>    "namespace": "AWS/Lambda"<br/>  },<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "FirstByteLatency",<br/>    "namespace": "AWS/S3"<br/>  },<br/>  {<br/>    "additional_statistics": [<br/>      "p50",<br/>      "p75",<br/>      "p95",<br/>      "p99"<br/>    ],<br/>    "metric_name": "TotalRequestLatency",<br/>    "namespace": "AWS/S3"<br/>  }<br/>]</pre> | no |
| <a name="input_s3_backup_custom_name"></a> [s3\_backup\_custom\_name](variables.tf#L171) | Set the name of the S3 backup bucket, otherwise variable '{firehose\_stream}-backup-metrics' will be used | `string` | `null` | no |
| <a name="input_existing_s3_backup"></a> [existing\_s3\_backup](variables.tf#L177) | Use an existing S3 bucket to use as a backup bucket | `string` | `null` | no |
| <a name="input_govcloud_deployment"></a> [govcloud\_deployment](variables.tf#L183) | Enable if you deploy the integration in govcloud | `bool` | `false` | no |
| <a name="input_custom_s3_bucket"></a> [custom\_s3\_bucket](variables.tf#L249) | Custom S3 bucket to use for the lambda processor | `string` | `null` | no |
| <a name="input_lambda_processor_version"></a> [lambda\_processor\_version](variables.tf#L255) | Version of the Lambda processor to deploy (0.1.18 or later; in GovCloud 0.1.19 or later). Leave unset for the default: 0.1.18, or 0.1.19 in GovCloud. Changing it updates the function code on the next apply. In GovCloud the FIPS build of this version is used. | `string` | `null` | no |
| <a name="input_server_side_encryption"></a> [server\_side\_encryption](variables.tf#L270) | Server side encryption configuration | <pre>object({<br/>    enabled  = bool<br/>    key_type = optional(string)<br/>    key_arn  = optional(string)<br/>  })</pre> | <pre>{<br/>  "enabled": false,<br/>  "key_type": "AWS_OWNED_CMK"<br/>}</pre> | no |
| <a name="input_static_labels"></a> [static\_labels](variables.tf#L288) | List of key-value pairs that will be added as labels to every metric in the integration. | `list(string)` | `[]` | no |
| <a name="input_derived_labels"></a> [derived\_labels](variables.tf#L294) | Rules that add a label copied from the first resource tag in `sources` that exists, isn't empty and isn't in `exclude_values` (case-insensitive). Optional `drop_values` drops data points where any final label with the `target` key matches (case-insensitive, requires processor v0.1.17 or later). Passed to the Lambda processor as DERIVED\_LABELS. Requires lambda\_processor\_enable. | <pre>list(object({<br/>    target         = string<br/>    sources        = list(string)<br/>    exclude_values = optional(list(string), [])<br/>    drop_values    = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_cross_account_enabled"></a> [cross\_account\_enabled](variables.tf#L321) | Enable cross-account resource tag enrichment for OAM. When true, the Lambda will assume roles in linked accounts to fetch resource tags. Requires cross\_account\_roles to be set. | `bool` | `false` | no |
| <a name="input_cross_account_roles"></a> [cross\_account\_roles](variables.tf#L327) | Map of AWS account IDs to IAM role ARNs for cross-account tag enrichment. Example: {"123456789012" = "arn:aws:iam::123456789012:role/CoralogixMetricsReader"} | `map(string)` | `{}` | no |
| <a name="input_lambda_processor_enable"></a> [lambda\_processor\_enable](variables.tf#L189) | Enable lambda processor function, defaults to true | `bool` | `true` | no |
| <a name="input_lambda_processor_custom_name"></a> [lambda\_processor\_custom\_name](variables.tf#L195) | Set the name of the lambda processor function, otherwise variable '{firehose\_stream}-metrics-transform' will be used | `string` | `null` | no |
| <a name="input_lambda_processor_iam_custom_name"></a> [lambda\_processor\_iam\_custom\_name](variables.tf#L201) | Set the name of the lambda processor IAM role & policy, otherwise variable '{firehose\_stream}-lambda-processor-iam' will be used | `string` | `null` | no |
| <a name="input_existing_lambda_processor_iam"></a> [existing\_lambda\_processor\_iam](variables.tf#L207) | Use an existing lambda processor IAM role | `string` | `null` | no |
| <a name="input_firehose_iam_custom_name"></a> [firehose\_iam\_custom\_name](variables.tf#L213) | Set the name of the firehose IAM role & policy, otherwise variable '{firehose\_stream}-firehose-metrics-iam' will be used | `string` | `null` | no |
| <a name="input_existing_firehose_iam"></a> [existing\_firehose\_iam](variables.tf#L219) | Use an existing IAM role to use as a firehose role | `string` | `null` | no |
| <a name="input_metric_streams_iam_custom_name"></a> [metric\_streams\_iam\_custom\_name](variables.tf#L225) | Set the name of the cloudwatch metric streams IAM role & policy, otherwise variable '{firehose\_stream}-cw-iam' will be used | `string` | `null` | no |
| <a name="input_existing_metric_streams_iam"></a> [existing\_metric\_streams\_iam](variables.tf#L231) | Use an existing IAM role to use as a metric streams role | `string` | `null` | no |
| <a name="input_user_supplied_tags"></a> [user\_supplied\_tags](variables.tf#L237) | Tags supplied by the user to populate to all generated resources | `map(string)` | `{}` | no |
| <a name="input_override_default_tags"></a> [override\_default\_tags](variables.tf#L243) | Override and remove the default tags by setting to true | `bool` | `false` | no |

> [!NOTE]
> In GovCloud the Lambda processor loads from the Coralogix distribution bucket `coralogix-public-artifacts-<region>`, which holds only the FIPS build, under `firehose-metrics-transformer-<version>.zip`, from 0.1.19 on. Leave `lambda_processor_version` unset to deploy 0.1.19, or pin 0.1.19 or later; an older pin fails at plan. To keep the code in your own bucket instead, set `custom_s3_bucket`: the module downloads the processor from the distribution bucket, checks its published SHA-256 and uploads it to that bucket. The machine running Terraform then needs `curl`, `sha256sum` or `shasum`, and the AWS CLI.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_firehose_stream_arn"></a> [firehose\_stream\_arn](#output\_firehose\_stream\_arn) | ARN of the Firehose Delivery Stream |
| <a name="output_firehose_stream_name"></a> [firehose\_stream\_name](#output\_firehose\_stream\_name) | Name of the Firehose Delivery Stream |
| <a name="output_firehose_iam_role_arn"></a> [firehose\_iam_role\_arn](#output\_firehose\_iam_role\_arn) | ARN of the Firehose IAM role |
| <a name="output_s3_backup_bucket_arn"></a> [s3\_backup\_bucket\_arn](#output\_s3\_backup\_bucket\_arn) | ARN of the Firehose S3 Backup Bucket |
| <a name="output_lambda_processor_arn"></a> [lambda\_processor\_arn](#output\_lambda\_processor\_arn) | ARN of the Lambda Processor |
| <a name="output_lambda_processor_iam_arn"></a> [lambda\_processor\_iam\_arn](#output\_lambda\_processor\_iam\_arn) | ARN of the Lambda Processor IAM role |
| <a name="output_metric_stream_arn"></a> [metric\_stream\_arn](#output\_metric\_stream\_arn) | ARN of the CloudWatch Metric Stream |
| <a name="output_metrics_stream_iam_role_arn"></a> [metrics\_stream\_iam\_role\_arn](#output\_metrics\_stream\_iam\_role\_arn) | ARN of the CloudWatch Metric Stream IAM role |

<!-- END_TF_DOCS -->
