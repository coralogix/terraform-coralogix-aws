# ECS EC2 Open Telemetry Agent

Terraform module to launch Opentelemetry Collector agents on an existing ECS Cluster on EC2 container instances. An ECS Service runs the [Coralogix Opentelemetry Collector](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) image as a Daemon task on each active container instance.

## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.

```terraform
module "ecs-ec2" {
  source                   = "../../modules/ecs-ec2"
  ecs_cluster_name         = "ecs-cluster-name"
  cdot_image_version       = "latest"
  memory                   = numeric MiB
  coralogix_region         = ["Europe"|"Europe2"|"India"|"Singapore"|"US"|"US2"|"Custom"]
  default_application_name = "Coralogix Application Name"
  default_subsystem_name   = "Coralogix Subsystem Name"
  private_key              = var.private_key
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

## Modules

No modules.

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
| image\_version | The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags | `string` | n/a | yes |
| memory | The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. Minimum "256" MiB. CPU Units will be allocated directly proportional to Memory. | `number` | `256` | no |
| metrics | If true, collects ECS task resource usage metrics (such as CPU, memory, network, and disk) and publishes to Coralogix. See: https://github.com/coralogix/coralogix-otel-collector/tree/master/receiver/awsecscontainermetricsdreceiver | `bool` | `false` | no |
| otel\_config\_file | File path to a custom opentelemetry configuration file. Defaults to an embedded configuration. See https://opentelemetry.io/docs/collector/configuration/ and https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/coralogixexporter | `string` | `null` | no |
| private\_key | The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/ | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| coralogix\_otel\_agent\_service\_id | ID of the ECS Service for the OTEL Agent Daemon |
| coralogix\_otel\_agent\_task\_definition\_arn | ARN of the ECS Task Definition for the OTEL Agent Daemon |
