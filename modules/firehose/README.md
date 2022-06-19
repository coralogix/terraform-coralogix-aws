When Using the variable 'include_metric_stream_namespaces' - the chosen namespaces are case-sensitive, therefore they must appear exactly like they appear in AWS, please see the [AWS namespaces list]: 
(https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)

# Metrics Output Format
Coralogix suppots both 'JSON' format and 'OpenTelemtry' format. 
The default format configured here is 'OpenTelemtry'. 

#### Note
if using 'Json' in the firehose output format, which is configured via the 'integration_type' variable,
then the CloudWatch metric stream must be configured with the same format, configured via the 'output_format' variable.

