# Coralogix OpenTelemetry Agent for ECS-EC2. Terraform module.

Terraform module to launch the Coralogix Distribution for Open Telemetry ("CDOT") into an existing AWS ECS Cluster, in the OTEL [Agent deployment](https://opentelemetry.io/docs/collector/deployment/agent/) pattern. The module is available on the [Terraform Registry](https://registry.terraform.io/modules/coralogix/aws/coralogix/latest/submodules/ecs-ec2).

The OTEL collector/agent/daemon image used is the [Coralogix Distribution for Open Telemetry](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) Docker Hub image. It is deployed as a [_Daemon_](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_daemon) ECS Task, i.e. one OTEL collector agent container on each EC2 instance (i.e. ECS container instance) across the cluster.

CDOT extends upon the main [Open Telemetry Collector Contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) project, adding features specifically to enhance integration with AWS ECS, among other improvements.

The OTEL agent is deployed as a Daemon ECS Task and connected using [```host``` network mode](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-networkmode-host.html). OTEL-instrumented application containers that need to send telemetry to the local OTEL agent can lookup the IP address of the CDOT container [using a number of methods](https://coralogix.com/docs/opentelemetry-using-ecs-ec2/#otel-agent-network-service-discovery), making it easier for Application Tasks using ```awsvpc``` and ```bridge``` network modes to connect with the OTEL agent. OTEL-instrumented application containers should also consider which resource attributes to use as telemetry identifiers.

The OTEL agent uses a [filelog receiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/filereceiver) to read the docker logs of all containers on the EC2 host. OTLP is also accepted. Coralogix provides the ```awsecscontainermetricsd``` receiver which enables metrics collection of all tasks on the same host. The [coralogix exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/coralogixexporter) forwards telemetry to your configured Coralogix endpoint.

The CDOT OTEL agent also features enhancements specific to ECS integration. These improvements are proprietary to the Coralogix Distribution for Open Telemetry.

The default OTEL collector traces are sampled at 10% rate using head sampling. Head sampling is a feature that allows you to sample traces at the collection point before any processing occurs. When enabled, it creates a separate pipeline for sampled traces using probabilistic sampling. This helps reduce the volume of traces while maintaining a representative sample.

The sampling configuration can be adjusted using the following parameters:
- `EnableHeadSampler`: Enable/disable head sampling
- `SamplerMode`: Choose between proportional, equalizing, or hash_seed sampling modes
- `SamplingPercentage`: Set the desired sampling rate (0-100%). The config can be customized.

The default OTEL collector config is available [with Head Sampling](otel_config.tftpl.yaml) and [without Head Sampling](otel_config_no_sampler.tftpl.yaml) options. The config can be customized.

For further details, see documentation: [AWS ECS-EC2 using OpenTelemetry](https://coralogix.com/docs/opentelemetry-using-ecs-ec2).

## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.
<!--For local dev, set local path to source, e.g. ```source  = "../../modules/ecs-ec2"```-->
```terraform
module "ecs-ec2" {
  source                              = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name                    = "ecs-cluster-name"
  image_version                       = "v0.4.0"
  memory                              = numeric MiB
  coralogix_region                    = ["EU1"|"EU2"|"AP1"|"AP2"|"AP3"|"US1"|"US2"|"custom"]
  default_application_name            = "Coralogix Application Name"
  default_subsystem_name              = "Coralogix Subsystem Name"
  # OPTIONAL
  api_key                             = "cxtp_CoralogixSendYourDataAPIKey"
  custom_domain                       = "custom.coralogix.domain"
  otel_config_file                    = "file path to custom OTEL collector config file"
  use_api_key_secret                  = true|false
  api_key_secret_arn                  = "ARN of the Secrets Manager secret containing the API key" 
  custom_config_parameter_store_name  = "NAME of the Parameter Store parameter containing the OTEL configuration"
  task_execution_role_arn             = "ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume"
}
```
<!-- To generate API docs below, delete below this line, and execute: ```terraform-docs markdown . >> README.md```-->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
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
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector. Supports Amazon EC2 instances only, not Fargate. | `string` | n/a | yes |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | The Coralogix Open Telemetry Distribution Image Version/Tag. See: https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | The OpenTelemetry Collector Image to use. Should accept default unless advised by Coralogix support. | `string` | `"coralogixrepo/coralogix-otel-collector"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount of memory (in MiB) used by the task. Note that your cluster must have sufficient memory available to support the given value. Minimum __256__ MiB. CPU Units will be allocated directly proportional to Memory. | `number` | `256` | no |
| <a name="input_coralogix_region"></a> [coralogix\_region](#input\_coralogix\_region) | The region of the Coralogix endpoint domain: [EU1\|EU2\|AP1\|AP2\|AP3\|US1\|US2\|custom]. If \"custom\" then __custom_domain__ parameter must be specified. | `string` | n/a | yes |
| <a name="input_custom_domain"></a> [custom\_domain](#input\_custom\_domain) | [Optional] Coralogix custom domain, e.g. \"private.coralogix.com\" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix_region__ parameter. | `string` | `null` | no |
| <a name="input_default_application_name"></a> [default\_application\_name](#input\_default\_application\_name) | The default Coralogix Application name. | `string` | n/a | yes |
| <a name="input_default_subsystem_name"></a> [default\_subsystem\_name](#input\_default\_subsystem\_name) | The default Coralogix Subsystem name. | `string` | n/a | yes |
| <a name="input_use_api_key_secret"></a> [use\_api\_key\_secret](#input\_use\_api\_key\_secret) | Whether to use API key stored in AWS Secrets Manager | `bool` | `false` | no |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/ | `string` | `null` | no |
| <a name="input_api_key_secret_arn"></a> [api\_key\_secret\_arn](#input\_api\_key\_secret\_arn) | ARN of the Secrets Manager secret containing the API key | `string` | `null` | no |
| <a name="input_use_custom_config_parameter_store"></a> [use\_custom\_config\_parameter\_store](#input\_use\_custom\_config\_parameter\_store) | Whether to use a custom config from Parameter Store | `bool` | `false` | no |
| <a name="input_custom_config_parameter_store_name"></a> [custom\_config\_parameter\_store\_name](#input\_custom\_config\_parameter\_store\_name) | Name of the Parameter Store parameter containing the OTEL configuration. If not provided, default configuration will be used | `string` | `null` | no |
| <a name="input_otel_config_file"></a> [otel\_config\_file](#input\_otel\_config\_file) | File path to a custom opentelemetry configuration file. Defaults to an embedded configuration. | `string` | `null` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `null` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | Existing Coralogix OTEL task definition ARN | `string` | `null` | no |
| <a name="input_enable_head_sampler"></a> [enable\_head\_sampler](#input\_enable\_head\_sampler) | Enable or disable head sampling for traces. When enabled, sampling decisions are made at the collection point before any processing occurs. | `bool` | `true` | no | 
| <a name="input_sampler_mode"></a> [sampler\_mode](#input\_sampler\_mode) | The sampling mode to use:<br>**proportional**: Maintains the relative proportion of traces across services.<br>**equalizing**: Attempts to sample equal numbers of traces from each service.<br>**hash_seed**: Uses consistent hashing to ensure the same traces are sampled across restarts.| `string` | `"proportional"` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input_sampling_percentage) | The percentage of traces to sample (0-100). A value of 100 means all traces will be sampled, while 0 means no traces will be sampled. | `number` | `10` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_coralogix_otel_agent_service_id"></a> [coralogix\_otel\_agent\_service\_id](#output\_coralogix\_otel\_agent\_service\_id) | ID of the ECS Service for the OTEL Agent Daemon |
| <a name="output_coralogix_otel_agent_task_definition_arn"></a> [coralogix\_otel\_agent\_task\_definition\_arn](#output\_coralogix\_otel\_agent\_task\_definition\_arn) | ARN of the ECS Task Definition for the OTEL Agent Daemon |
