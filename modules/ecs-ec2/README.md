# ECS EC2 Open Telemetry Agent

Terraform module to launch Opentelemetry Collector agents on an existing ECS Cluster on EC2 container instances. An ECS Service runs the [Coralogix Opentelemetry Collector](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) image as a Daemon task on each active container instance.

## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.

```terraform
module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "ecs-cluster-name"
  image_version            = "latest"
  memory                   = numeric MiB
  coralogix_region         = ["Europe"|"Europe2"|"India"|"Singapore"|"US"|"US2"]
  custom_domain            = "your custom Coralogix domain"
  default_application_name = "Coralogix Application Name"
  default_subsystem_name   = "Coralogix Subsystem Name"
  api_key                  = var.api_key
  otel_config_file         = "[optional] file path to custom OTEL collector config file"
  metrics                  = [true|false]
}
```

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
| api\_key | The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/ | `string` | n/a | yes |
| coralogix\_region | The region of the Coralogix endpoint domain: [Europe, Europe2, India, Singapore, US, US2, Custom]. If "Custom" then __custom\_domain__ parameter must be specified. | `string` | n/a | yes |
| custom\_domain | [Optional] Coralogix custom domain, e.g. "private.coralogix.com" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix\_region__ parameter. | `string` | `null` | no |
| default\_application\_name | The default Coralogix Application name. | `string` | n/a | yes |
| default\_subsystem\_name | The default Coralogix Subsystem name. | `string` | n/a | yes |
| ecs\_cluster\_name | Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate. | `string` | n/a | yes |
| image | The OpenTelemetry Collector Image to use. Should accept default unless advised by Coralogix support. | `string` | `"coralogixrepo/coralogix-otel-collector"` | no |
| image\_version | The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags | `string` | n/a | yes |
| memory | The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. Minimum __256__ MiB. CPU Units will be allocated directly proportional to Memory. | `number` | `256` | no |
| metrics | Toggles Metrics collection of ECS Task resource usage (such as CPU, memory, network, and disk) and publishes to Coralogix. Default __'false'__ . Note that Logs and Traces are always enabled. | `bool` | `false` | no |
| otel\_config\_file | File path to a custom opentelemetry configuration file. Defaults to an embedded configuration. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| coralogix\_otel\_agent\_service\_id | ID of the ECS Service for the OTEL Agent Daemon |
| coralogix\_otel\_agent\_task\_definition\_arn | ARN of the ECS Task Definition for the OTEL Agent Daemon |
