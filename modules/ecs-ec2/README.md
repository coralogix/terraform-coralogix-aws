# Coralogix OpenTelemetry Agent for ECS-EC2. Terraform module.

Terraform module to launch the Coralogix Distribution for Open Telemetry ("CDOT") into an existing AWS ECS Cluster, in the OTEL [Agent deployment](https://opentelemetry.io/docs/collector/deployment/agent/) pattern. The module is available on the [Terraform Registry](https://registry.terraform.io/modules/coralogix/aws/coralogix/latest/submodules/ecs-ec2).

The OTEL collector/agent/daemon image used is the [Coralogix Distribution for Open Telemetry](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) Docker Hub image. It is deployed as a [_Daemon_](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_daemon) ECS Task, i.e. one OTEL collector agent container on each EC2 instance (i.e. ECS container instance) across the cluster.

CDOT extends upon the main [Open Telemetry Collector Contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) project, adding features specifically to enhance integration with AWS ECS, among other improvements.

The OTEL agent is deployed as a Daemon ECS Task and connected using [```host``` network mode](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-networkmode-host.html). OTEL-instrumented application containers that need to send telemetry to the local OTEL agent can lookup the IP address of the CDOT container [using a number of methods](https://coralogix.com/docs/opentelemetry-using-ecs-ec2/#otel-agent-network-service-discovery), making it easier for Application Tasks using ```awsvpc``` and ```bridge``` network modes to connect with the OTEL agent. OTEL-instrumented application containers should also consider which resource attributes to use as telemetry identifiers.

The OTEL agent uses a [filelog receiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/filereceiver) to read the docker logs of all containers on the EC2 host. OTLP is also accepted. Coralogix provides the ```awsecscontainermetricsd``` receiver which enables metrics collection of all tasks on the same host. The [coralogix exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/coralogixexporter) forwards telemetry to your configured Coralogix endpoint.

The CDOT OTEL agent also features enhancements specific to ECS integration. These improvements are proprietary to the Coralogix Distribution for Open Telemetry.

The default OTEL collector config is available [with metrics](otel_config_metrics.tftpl.yaml) and [without metrics](otel_config.tftpl.yaml) options. The config can be customized.

For further details, see documentation: [AWS ECS-EC2 using OpenTelemetry](https://coralogix.com/docs/opentelemetry-using-ecs-ec2).

## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.
<!--For local dev, set local path to source, e.g. ```source  = "../../modules/ecs-ec2"```-->
```terraform
module "ecs-ec2" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = "ecs-cluster-name"
  image_version            = "latest"
  memory                   = numeric MiB
  coralogix_region         = ["EU1"|"EU2"|"AP1"|"AP2"|"US1"|"US2"]
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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.24.0 |

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
