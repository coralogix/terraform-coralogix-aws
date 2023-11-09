# ECS EC2 Open Telemetry Agent

Terraform module to launch Opentelemetry Collector agents on an existing ECS Cluster on EC2 container instances. An ECS Service runs the [Coralogix Opentelemetry Collector](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) image as a Daemon task on each active container instance.

## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.

```terraform
module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "ecs-cluster-name"
  cdot_image_version       = "latest"
  memory                   = 256
  coralogix_region         = ["Europe"|"Europe2"|"India"|"Singapore"|"US"|"US2"|"Custom"]
  default_application_name = "Coralogix Application Name"
  private_key              = var.private_key
  metrics                  = [true|false]
}
```
> TODO after merge, update ```source``` to: "github.com/coralogix/terraform-coralogix-aws//modules/ecs-ec2"

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.1 |
| aws | >= 4.15.1 |

## Providers

| Name | Version |
|------|---------|
| aws | 5.24.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.coralogix_otel_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.coralogix_otel_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| coralogix\_region | The Coralogix location region, [Europe, Europe2, India, Singapore, US, US2] | `string` | n/a | yes |
| default\_application\_name | The default Coralogix Application name. | `string` | n/a | yes |
| default\_subsystem\_name | The default Coralogix Subsystem name. | `string` | `"default"` | no |
| ecs\_cluster\_name | Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate. | `string` | n/a | yes |
| image | The OpenTelemetry Collector Image to use. Defaults to "coralogixrepo/coralogix-otel-collector". Should accept default unless advised by Coralogix support. | `string` | `"coralogixrepo/coralogix-otel-collector"` | no |
| image\_version | The Coralogix Open Telemetry Distribution Image Version/Tag. Defaults to "latest". See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags | `string` | `"latest"` | no |
| memory | The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. | `number` | `256` | no |
| metrics | If true, cadivisor will be deployed on each node to collect metrics | `bool` | `false` | no |
| otel\_config | The opentelemetry configuration as a base64 encoded string. Defaults to an embedded configuration. Should accept default unless advised by Coralogix support. | `string` | `null` | no |
| private\_key | The Coralogix Send-Your-Data API key for your Coralogix account. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| coralogix\_otel\_agent\_service\_id | ID of the ECS Service for the OTEL Agent Daemon |
| coralogix\_otel\_agent\_task\_definition\_arn | ARN of the ECS Task Definition for the OTEL Agent Daemon |
