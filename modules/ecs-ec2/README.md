# ECS EC2 Open Telemetry Agent

Terraform module to launch Opentelemetry Collector [Agents](https://opentelemetry.io/docs/collector/deployment/agent/) into an existing ECS Cluster. The [Coralogix Opentelemetry Collector](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) Docker image is deployed as a Daemon ECS Task, running one OTEL Collector on each EC2 container instance.

## About the OTEL Collector

TODO..
ports
functionality.
diagram.
otel networking.
resource attributes


## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.
<!--For local dev, set local path to source, e.g. ```source  = "../../modules/ecs-ec2"```-->
```terraform
module "ecs-ec2" {
  source                   = "github.com/coralogix/terraform-coralogix-aws/modules/ecs-ec2"
  ecs_cluster_name         = "ecs-cluster-name"
  image_version            = "latest"
  memory                   = numeric MiB
  coralogix_region         = ["Europe"|"Europe2"|"India"|"Singapore"|"US"|"US2"]
  custom_domain            = "[optional] custom Coralogix domain"
  default_application_name = "Coralogix Application Name"
  default_subsystem_name   = "Coralogix Subsystem Name"
  api_key                  = var.api_key
  otel_config_file         = "[optional] file path to custom OTEL collector config file"
  metrics                  = [true|false]
}
```
<!-- To generate API docs below, delete below this line, and execute: ```terraform-docs markdown . >> README.md```-->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.24.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.24.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.coralogix_otel_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.coralogix_otel_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [random_string.id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/ | `string` | n/a | yes |
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The region of the Coralogix endpoint domain: [Europe, Europe2, India, Singapore, US, US2, Custom]. If "Custom" then __custom\_domain__ parameter must be specified. | `string` | n/a | yes |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | [Optional] Coralogix custom domain, e.g. "private.coralogix.com" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix\_region__ parameter. | `string` | `null` | no |
| <a name="input_default_application_name"></a> [default\_application\_name](#input\_default\_application\_name) | The default Coralogix Application name. | `string` | n/a | yes |
| <a name="input_default_subsystem_name"></a> [default\_subsystem\_name](#input\_default\_subsystem\_name) | The default Coralogix Subsystem name. | `string` | n/a | yes |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate. | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The OpenTelemetry Collector Image to use. Should accept default unless advised by Coralogix support. | `string` | `"coralogixrepo/coralogix-otel-collector"` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. Minimum __256__ MiB. CPU Units will be allocated directly proportional to Memory. | `number` | `256` | no |
| <a name="input_metrics"></a> [metrics](#input\_metrics) | Toggles Metrics collection of ECS Task resource usage (such as CPU, memory, network, and disk) and publishes to Coralogix. Default __'false'__ . Note that Logs and Traces are always enabled. | `bool` | `false` | no |
| <a name="input_otel_config_file"></a> [otel\_config\_file](#input\_otel\_config\_file) | File path to a custom opentelemetry configuration file. Defaults to an embedded configuration. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `null` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | Existing Coralogix OTEL task definition ARN | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_coralogix_otel_agent_service_id"></a> [coralogix\_otel\_agent\_service\_id](#output\_coralogix\_otel\_agent\_service\_id) | ID of the ECS Service for the OTEL Agent Daemon |
| <a name="output_coralogix_otel_agent_task_definition_arn"></a> [coralogix\_otel\_agent\_task\_definition\_arn](#output\_coralogix\_otel\_agent\_task\_definition\_arn) | ARN of the ECS Task Definition for the OTEL Agent Daemon |
