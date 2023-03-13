# EventBridge Module
Configuration in this directory creates eventbridge to send the aws events to your coralogix account.

## Usage
```
module "eventbridge_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/eventbridge"
  eventbridge_stream             = var.coralogix_eventbridge_stream_name
  sources                        = var.eventbridge_sources
  role_name                      = var.eventbridge_role_name
  private_key                    = var.coralogix_privatekey
  coralogix_region               = var.coralogix_region
}
```


### Examples
Examples can be found under the [examples directory](https://github.com/coralogix/terraform-coralogix-aws/blob/master/examples/eventbridge)


# Coralogix account region
The coralogix region variable accepts one of the following regions:
* us
* singapore
* ireland
* india
* stockholm

### All of the regions must be written with lower-case letters. 

| Region    | Logs Endpoint
|-----------|-----------------------------------------------------------------|
| us        | `https://aws-events.coralogix.us/aws/event`                |
| singapore | `https://aws-events.coralogixsg.com/aws/event`             |
| ireland   | `https://aws-events.coralogix.com/aws/event`               |
| india     | `https://aws-events.coralogix.in/aws/event`            |
| stockholm | `https://aws-events.eu2.coralogix.com/aws/event` |


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
