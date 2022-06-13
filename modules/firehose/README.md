When Using the variable 'include_metric_stream_namespaces' - the chosen namespaces are case-sensitive, therefore they must appear exactly like they appear in AWS, please see the [AWS namespaces list]: 
(https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)

example: 
```
terraform {
  backend "local" {
    path = "./terraform.tfstate"
   }
}

module "cloudwatch_firehose_coralogix" {
    source = "./modules/kinesis-firehose"
    firehose_stream = var.coralogix_firehose_stream_name
    endpoint_url = var.coralogix_endpoint_url
    privatekey = var.coralogix_privatekey
    include_all_namespaces = false
    include_metric_stream_namespaces = ["ec2", "dynamodb"]
    enable_cloudwatch_metricstream = false
}```

export TF_VAR_coralogix_privatekey="your-private-key"
export TF_VAR_coralogix_endpoint_url="https://firehose-ingress.eu2.coralogix.com/firehose"
