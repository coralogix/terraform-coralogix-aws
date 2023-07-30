# EventBridge Module
Configuration in this directory creates eventbridge to send the aws events to your coralogix account.

## Usage
```
module "eventbridge_coralogix" {
  source                         = "github.com/coralogix/terraform-coralogix-aws//modules/eventbridge"
  eventbridge_stream             = var.coralogix_eventbridge_stream_name
  role_name                      = var.eventbridge_role_name
  private_key                    = var.coralogix_privatekey
  coralogix_region               = var.coralogix_region
  custom_url                     = var.custom_url
  sources                        = var.eventbridge_sources
  application_name               = var.application_name
  policy_name                    = var.policy_name
}
```

* Override Coralogix applicationName:
The application name by default is the eventbridge delivery stream name, but it can be overriden by setting an environment variable called `application_name`.

### Coralogix account region
The coralogix region variable accepts one of the following regions:
* us
* singapore
* ireland
* india
* stockholm
* custom

*** All of the regions must be written with lower-case letters. 

### Endpoints

| Region    | Logs Endpoint
|-----------|-----------------------------------------------------------------|
| us        | `https://aws-events.coralogix.us/aws/event`                |
| us2       | `https://aws-events.cx498.coralogix.com/aws/event`         |
| singapore | `https://aws-events.coralogixsg.com/aws/event`             |
| ireland   | `https://aws-events.coralogix.com/aws/event`               |
| india     | `https://aws-events.coralogix.in/aws/event`            |
| stockholm | `https://aws-events.eu2.coralogix.com/aws/event` |


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
| [aws_cloudwatch_event_api_destination.api-connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_api_destination) | resource |
| [aws_cloudwatch_event_connection.event-connectiong](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) | resource |
| [aws_cloudwatch_event_rule.eventbridge_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.my_event_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_policy.eventbridge_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eventbridge_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.eventbridge_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current_identity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Coralogix application name | `string` | `null` | no |
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | Coralogix account region: us, us2, singapore, ireland, india, stockholm [in lower-case letters] | `any` | n/a | yes |
| <a name="input_custom_url"></a> [custom_url](#input\_custom\_url) | Custom coralogix url | `string` | `null` | no |
| <a name="input_eventbridge_stream"></a> [eventbridge\_stream](#input\_eventbridge\_stream) | AWS eventbridge delivery stream name | `string` | n/a | yes |
| <a name="input_private_key"></a> [private\_key](#input\_private\_key) | Your Coralogix private key | `string` | n/a | yes |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | The name of the eventbridge role | `string` | n/a | yes |
| <a name="input_sources"></a> [sources](#input\_sources) | The services for which we will send events | `list(any)` | <pre>[<br>  "aws.ec2",<br>  "aws.autoscaling",<br>  "aws.cloudwatch",<br>  "aws.events",<br>  "aws.health",<br>  "aws.rds"<br>]</pre> | no |
| <a name="input_policy_name"></a> [policy_name](#input\_custom\_url) | Custom aws_iam_policy | `string` | `EventBridge_policy` | no |

## Coralgoix regions
| Coralogix region | AWS Region | Coralogix Domain |
|------|------------|------------|
| `Ireland` |  `eu-west-1` | coralogix.com |
| `Stockholm` | `eu-north-1` | eu2.coralogix.com |
| `India` | `ap-south-1`  | coralogix.in |
| `Singapore` | `ap-southeast-1` | coralogixsg.com |
| `US` | `us-east-2` | coralogix.us |
| `US2` | `us-west-2` | cx498.coralogix.com |

## Outputs

No outputs.


## Events Sources
### EC2
* AWS API call via cloudtrail
* EBS Fast Snapshot Restore State-change Notification
* EBS Multi-Volume Snapshots Completion Status
* EBS Snapshot Notification
* EBS Volume Notification
* EC2 AMI State Change
* EC2 Fast Launch State-change Notification
* EC2 Instance Rebalance Recommendation
* EC2 Instance State-change Notification
* EC2 Spot Instance Interruption Warning
* EC2 Spot Instance Request Fulfillment
### AutoScaling
* AWS API call via cloudtrail
* Instance launch and terminate
* Instance refresh
### Cloudwatch
* AWS API call via cloudtrail
* CloudWatch alarm state change
* CloudWatch alarm configuration change
### Events
* AWS API call via cloudtrail
* EventBridge scheduled event
### Health 
* AWS API call via cloudtrail
* Specific health events
### RDS
* AWS API call via cloudtrail
* DB cluster event
* DB cluster snapshot event
* DB instance event
* DB parameter group event
* DB security group event
* DB snapshot event

For further information on additional events sources and event types, see [this AWS doc](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-service-event.html)

### Examples
Examples can be found under the [examples directory](https://github.com/coralogix/terraform-coralogix-aws/blob/master/examples/eventbridge)
