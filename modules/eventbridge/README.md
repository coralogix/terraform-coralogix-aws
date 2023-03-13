# EventBridge_module_toCoralogix
Configuration in this directory creates eventbridge to send the aws events to your coralogix account.

## Metrics - Usage
### Provision a eventbridge stream for streaming events to Coralogix  Delivery Stream

#### Creating api destination
```
resource "aws_cloudwatch_event_api_destination" "api-connection" {
  name                             = "toCoralogix"
  description                      = "EventBridge Api destination to Coralogix"
  invocation_endpoint              = local.endpoint_url[var.coralogix_region].url
  http_method                      = "POST"
  invocation_rate_limit_per_second = 300
  connection_arn                   = aws_cloudwatch_event_connection.event-connectiong.arn
}
```
#### Connecting api destination to your coralogix account
```
esource "aws_cloudwatch_event_connection" "event-connectiong" {
  name               = "coralogixConnection"
  description        = "This is Coralogix connection for Evenbridge"
  authorization_type = "API_KEY"

  auth_parameters {
    api_key {
      key   = "x-amz-event-bridge-access-key"
      value = var.private_key
    }
  }
}
```

### Delivering all Eventbridge events
Provision a Eventbridge delivery rule with [Events from AWS services](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-event.html).
and sends the events to Coralogix:
### Creating Rule for classify the events we want to get
You can send all event or select certain services that you interested.

```
resource "aws_cloudwatch_event_rule" "console" {
  name        = "Eventbridge rule"
  description = "Capture the main events"
///A number of services that we think are relevant to monitor, sub-alerts can be changed and classified
  event_pattern = <<PATTERN
{
  "source": [
    "aws.ec2", "aws.apigateway", "aws.es", "aws.health", "aws.rds", "aws.autoscaling", "aws.s3", "aws.dynamodb", "aws.cloudtrail", "aws.cloudwatch", "aws.managedservices"}
}
PATTERN
}
```

### Delivering selected Eventbridge events

```
resource "aws_cloudwatch_event_target" "example" {
  arn  = aws_cloudwatch_event_api_destination.api-connection.arn
  rule = aws_cloudwatch_event_rule.console.name
  role_arn = var.role_to_use
}
```


### Examples
Examples can be found under the [examples directory](https://github.com/coralogix/fork_EventBridge_module)

## Override Coralogix applicationName
The application name by default is the aws account, but it  will be overriden in futuret on setting an environment variable called `application_name`. 

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
| us        | `https://aws-events.coralogix.us/aws/event`                |
| singapore | `https://aws-events.coralogixsg.com/aws/event`             |
| ireland   | `https://aws-events.coralogix.com/aws/event`               |
| india     | `https://aws-events.coralogix.in/aws/event`            |
| stockholm | `https://aws-events.eu2.coralogix.com/aws/event` |

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Resources
| Name | Type |
|------|------|
| [aws_cloudwatch_event_api_destination.api-connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_api_destination) | resource |
| [aws_cloudwatch_event_connection.event-connectiong](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) | resource |
| [aws_cloudwatch_event_rule.console](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |


## Inputs


| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | Your aws account that you want to connect to coralogix | `number` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Your aws region that you want to connect to coralogix | `string` | n/a | yes |
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: us, singapore, ireland, india, stockholm [in lower-case letters] | `any` | n/a | yes |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | Your Coralogix private key | `string` | n/a | yes |
| <a name="input_role_to_use"></a> [role\_to\_use](#input\_role\_to\_use) | The role you want to give to the eventbridge | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Authors
Module is maintained by [Raz goldenberg](https://github.com/orgs/coralogix/people/Raz-goldenberg)
