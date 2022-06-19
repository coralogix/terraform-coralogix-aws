When Using the variable 'include_metric_stream_namespaces' - the chosen namespaces are case-sensitive, therefore they must appear exactly like they appear in AWS, please see the [AWS namespaces list]: 
(https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/aws-services-cloudwatch-metrics.html)

 ## Coralogix Endpoints

 | Region    | Metrics Endpoint
 |-----------|-----------------------------------------------------------------|
 | US        | `https://firehose-ingress.coralogix.us/firehose`                |
 | Singapore | `https://firehose-ingress.coralogixsg.com/firehose`             |
 | Ireland   | `https://firehose-ingress.coralogix.com/firehose`               |
 | India     | `https://firehose-ingress.app.coralogix.in/firehose`            |
 | Stockholm | `https://firehose-ingress.coralogix.eu2.coralogix.com/firehose` |

# Metrics Output Format
Coralogix suppots both 'JSON' format and 'OpenTelemtry' format. 
The default format configured here is 'OpenTelemtry'. 

#### Note
if using 'Json' in the firehose output format, which is configured via the 'integration_type' variable,
then the CloudWatch metric stream must be configured with the same format, configured via the 'output_format' variable.

