Usage
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
us
singapore
ireland
india
stockholm

# Metrics Output Format
Coralogix suppots both 'JSON' format and 'OpenTelemtry' format. 
The default format configured here is 'OpenTelemtry'. 
#### Note
if using 'Json' in the firehose output format, which is configured via the 'integration_type' variable,
then the CloudWatch metric stream must be configured with the same format, configured via the 'output_format' variable.
