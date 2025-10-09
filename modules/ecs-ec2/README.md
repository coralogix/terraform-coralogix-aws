# Coralogix OpenTelemetry Agent for ECS-EC2. Terraform module.

Terraform module to launch the Coralogix Distribution for Open Telemetry ("CDOT") into an existing AWS ECS Cluster, in the OTEL [Agent deployment](https://opentelemetry.io/docs/collector/deployment/agent/) pattern. The module is available on the [Terraform Registry](https://registry.terraform.io/modules/coralogix/aws/coralogix/latest/submodules/ecs-ec2).

The OTEL collector/agent/daemon image used is the [Coralogix Distribution for Open Telemetry](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) Docker Hub image. It is deployed as a [_Daemon_](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_daemon) ECS Task, i.e. one OTEL collector agent container on each EC2 instance (i.e. ECS container instance) across the cluster.

CDOT extends upon the main [Open Telemetry Collector Contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) project, adding features specifically to enhance integration with AWS ECS, among other improvements.

The OTEL agent is deployed as a Daemon ECS Task and connected using [```host``` network mode](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-networkmode-host.html). OTEL-instrumented application containers that need to send telemetry to the local OTEL agent can lookup the IP address of the CDOT container [using a number of methods](https://coralogix.com/docs/opentelemetry-using-ecs-ec2/#otel-agent-network-service-discovery), making it easier for Application Tasks using ```awsvpc``` and ```bridge``` network modes to connect with the OTEL agent. OTEL-instrumented application containers should also consider which resource attributes to use as telemetry identifiers.

The OTEL agent uses a [filelog receiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/filereceiver) to read the docker logs of all containers on the EC2 host. OTLP is also accepted. Coralogix provides the ```awsecscontainermetricsd``` receiver which enables metrics collection of all tasks on the same host. The [coralogix exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/coralogixexporter) forwards telemetry to your configured Coralogix endpoint.

The CDOT OTEL agent also features enhancements specific to ECS integration. These improvements are proprietary to the Coralogix Distribution for Open Telemetry.

## Features

### Head Sampling
The default OTEL collector traces are sampled at 10% rate using head sampling. Head sampling is a feature that allows you to sample traces at the collection point before any processing occurs. When enabled, it creates a separate pipeline for sampled traces using probabilistic sampling. This helps reduce the volume of traces while maintaining a representative sample.

The sampling configuration can be adjusted using the following parameters:
- `enable_head_sampler`: Enable/disable head sampling
- `sampler_mode`: Choose between proportional, equalizing, or hash_seed sampling modes
- `sampling_percentage`: Set the desired sampling rate (0-100%)

### Span Metrics
Span metrics generation is enabled by default. This feature automatically generates metrics from your traces, providing insights into your application's performance. The metrics include:
- Request counts
- Duration histograms
- Error rates
- Database operation metrics (when enabled)

You can control span metrics generation using:
- `enable_span_metrics`: Enable/disable span metrics generation

### Database Traces
Database operation metrics can be enabled to track performance of database operations. This feature provides detailed metrics about:
- Database operation counts
- Operation durations
- Error rates
- Operation types
- Database names and collections

You can control database traces using:
- `enable_traces_db`: Enable/disable database traces

### Health Checks
ECS container health checks can be enabled to monitor the OTEL collector's health status. Health checks use the `/healthcheck` binary that is available in OTEL collector versions v0.4.2 and later.

You can control health checks using:
- `health_check_enabled`: Enable/disable ECS container health checks
- `health_check_interval`: Health check interval in seconds (default: 30)
- `health_check_timeout`: Health check timeout in seconds (default: 5)
- `health_check_retries`: Number of health check retries (default: 3)
- `health_check_start_period`: Health check start period in seconds (default: 10)

**Note:** Health checks require OTEL collector image version v0.4.2 or later, as the `/healthcheck` binary was added in that version.

## Configuration Sources
The module supports multiple configuration sources for the OpenTelemetry Collector:

### Template Configuration (Default)
Uses built-in template configuration with customizable sampling and feature flags. The appropriate configuration file is automatically selected based on your feature requirements:

1. Basic sampling without spanmetrics or db metrics
2. Sampling with spanmetrics enabled
3. Sampling with both spanmetrics and db metrics enabled
4. No sampling with spanmetrics enabled
5. No sampling with both spanmetrics and db metrics enabled

### S3 Configuration
Use configuration files stored in S3. This allows for:
- Centralized configuration management
- Version control for configurations
- Dynamic configuration updates without redeploying the ECS service
- Custom configurations that go beyond the template options

The S3 configuration uses the OpenTelemetry Collector's S3 provider to fetch configuration files directly from S3 buckets.

### Parameter Store Configuration
Use configuration stored in AWS Systems Manager Parameter Store. This allows for:
- Secure configuration storage
- Integration with AWS Secrets Manager
- Centralized configuration management

## Usage

Provision an ECS Service that run the OTEL Collector Agent as a Daemon container on each EC2 container instance.
<!--For local dev, set local path to source, e.g. ```source  = "../../modules/ecs-ec2"```-->
```terraform
# Template Configuration (Default)
module "ecs-ec2" {
  source                              = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name                    = "ecs-cluster-name"
  image_version                       = "v0.5.0"
  coralogix_region                    = "EU1"
  # Optional: default_application_name = "Coralogix Application Name"  # defaults to "otel"
  # Optional: default_subsystem_name   = "Coralogix Subsystem Name"    # defaults to "ecs-ec2"
  api_key                             = "cxtp_CoralogixSendYourDataAPIKey"=
}

# S3 Configuration
module "ecs-ec2-s3" {
  source                              = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name                    = "ecs-cluster-name"
  image_version                       = "v0.5.0"
  coralogix_region                    = "EU1"
  # Optional: default_application_name = "Coralogix Application Name"  # defaults to "otel"
  # Optional: default_subsystem_name   = "Coralogix Subsystem Name"    # defaults to "ecs-ec2"
  api_key                             = "cxtp_CoralogixSendYourDataAPIKey"
  # S3 Configuration
  config_source                       = "s3"
  s3_config_bucket                    = "my-otel-config-bucket"
  s3_config_key                       = "configs/otel-config.yaml"
}

# Parameter Store Configuration
module "ecs-ec2-parameter-store" {
  source                              = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name                    = "ecs-cluster-name"
  image_version                       = "v0.5.0"
  coralogix_region                    = "EU1"
  # Optional: default_application_name = "Coralogix Application Name"  # defaults to "otel"
  # Optional: default_subsystem_name   = "Coralogix Subsystem Name"    # defaults to "ecs-ec2"
  api_key                             = "cxtp_CoralogixSendYourDataAPIKey"
  # Parameter Store Configuration
  config_source                       = "parameter-store"
  custom_config_parameter_store_name  = "otel-config"
  task_execution_role_arn             = "ARN of the task execution role that have access to the parameter store"
}
```

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
| <a name="input_default_application_name"></a> [default\_application\_name](#input\_default\_application\_name) | The default Coralogix Application name. | `string` | `"otel"` | no |
| <a name="input_default_subsystem_name"></a> [default\_subsystem\_name](#input\_default\_subsystem\_name) | The default Coralogix Subsystem name. | `string` | `"ecs-ec2"` | no |
| <a name="input_use_api_key_secret"></a> [use\_api\_key\_secret](#input\_use\_api\_key\_secret) | Whether to use API key stored in AWS Secrets Manager | `bool` | `false` | no |
| <a name="input_api_key"></a> [api\_key](#input\_api\_key) | The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/ | `string` | `null` | no |
| <a name="input_api_key_secret_arn"></a> [api\_key\_secret\_arn](#input\_api\_key\_secret\_arn) | ARN of the Secrets Manager secret containing the API key | `string` | `null` | no |
| <a name="input_use_custom_config_parameter_store"></a> [use\_custom\_config\_parameter\_store](#input\_use\_custom\_config\_parameter\_store) | Whether to use a custom config from Parameter Store | `bool` | `false` | no |
| <a name="input_custom_config_parameter_store_name"></a> [custom\_config\_parameter\_store\_name](#input\_custom\_config\_parameter\_store\_name) | Name of the Parameter Store parameter containing the OTEL configuration. If not provided, default configuration will be used | `string` | `null` | no |
| <a name="input_otel_config_file"></a> [otel\_config\_file](#input\_otel\_config\_file) | File path to a custom opentelemetry configuration file. Defaults to an embedded configuration. | `string` | `null` | no |
| <a name="input_task_execution_role_arn"></a> [task\_execution\_role\_arn](#input\_task\_execution\_role\_arn) | ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. When using S3 configuration, if not provided, an auto-created role with S3 read permissions will be used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Resource tags | `map(string)` | `null` | no |
| <a name="input_task_definition_arn"></a> [task\_definition\_arn](#input\_task\_definition\_arn) | Existing Coralogix OTEL task definition ARN | `string` | `null` | no |
| <a name="input_enable_head_sampler"></a> [enable\_head\_sampler](#input\_enable\_head\_sampler) | Enable or disable head sampling for traces. When enabled, sampling decisions are made at the collection point before any processing occurs. | `bool` | `true` | no | 
| <a name="input_sampler_mode"></a> [sampler\_mode](#input\_sampler\_mode) | The sampling mode to use:<br>**proportional**: Maintains the relative proportion of traces across services.<br>**equalizing**: Attempts to sample equal numbers of traces from each service.<br>**hash_seed**: Uses consistent hashing to ensure the same traces are sampled across restarts.| `string` | `"proportional"` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input_sampling_percentage) | The percentage of traces to sample (0-100). A value of 100 means all traces will be sampled, while 0 means no traces will be sampled. | `number` | `10` | no |
| <a name="input_enable_span_metrics"></a> [enable\_span\_metrics](#input\_enable\_span\_metrics) | Enable or disable span metrics generation. When enabled, metrics are automatically generated from your traces. | `bool` | `true` | no |
| <a name="input_enable_traces_db"></a> [enable\_traces\_db](#input\_enable\_traces\_db) | Enable or disable database traces. When enabled, detailed metrics about database operations are collected. | `bool` | `false` | no |
| <a name="input_health_check_enabled"></a> [health\_check\_enabled](#input\_health\_check\_enabled) | Enable ECS container health check for the OTEL agent container. Requires OTEL collector image version v0.4.2 or later. | `bool` | `false` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Health check interval in seconds. Only used if health_check_enabled is true. | `number` | `30` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Health check timeout in seconds. Only used if health_check_enabled is true. | `number` | `5` | no |
| <a name="input_health_check_retries"></a> [health\_check\_retries](#input\_health\_check\_retries) | Health check retries. Only used if health_check_enabled is true. | `number` | `3` | no |
| <a name="input_health_check_start_period"></a> [health\_check\_start\_period](#input\_health\_check\_start\_period) | Health check start period in seconds. Only used if health_check_enabled is true. | `number` | `10` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_coralogix_otel_agent_service_id"></a> [coralogix\_otel\_agent\_service\_id](#output\_coralogix\_otel\_agent\_service\_id) | ID of the ECS Service for the OTEL Agent Daemon |
| <a name="output_coralogix_otel_agent_task_definition_arn"></a> [coralogix\_otel\_agent\_task\_definition\_arn](#output\_coralogix\_otel\_agent\_task\_definition\_arn) | ARN of the ECS Task Definition for the OTEL Agent Daemon |
