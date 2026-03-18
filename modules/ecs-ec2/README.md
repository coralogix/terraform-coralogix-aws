# Coralogix OpenTelemetry Agent for ECS-EC2. Terraform module.

Terraform module to launch the Coralogix Distribution for Open Telemetry ("CDOT") into an existing AWS ECS Cluster, in the OTEL [Agent deployment](https://opentelemetry.io/docs/collector/deployment/agent/) pattern.

The OTEL collector/agent/daemon image used is the [Coralogix Distribution for Open Telemetry](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) Docker Hub image. It is deployed as a [_Daemon_](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs_services.html#service_scheduler_daemon) ECS Task, i.e. one OTEL collector agent container on each EC2 instance (i.e. ECS container instance) across the cluster.

CDOT extends upon the main [Open Telemetry Collector Contrib](https://github.com/open-telemetry/opentelemetry-collector-contrib) project, adding features specifically to enhance integration with AWS ECS, among other improvements.

The OTEL agent is deployed as a Daemon ECS Task and connected using [```host``` network mode](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/networking-networkmode-host.html). OTEL-instrumented application containers that need to send telemetry to the local OTEL agent can lookup the IP address of the CDOT container [using a number of methods](https://coralogix.com/docs/opentelemetry-using-ecs-ec2/#otel-agent-network-service-discovery), making it easier for Application Tasks using ```awsvpc``` and ```bridge``` network modes to connect with the OTEL agent. OTEL-instrumented application containers should also consider which resource attributes to use as telemetry identifiers.

The OTEL agent uses a [filelog receiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/filereceiver) to read the docker logs of all containers on the EC2 host. OTLP is also accepted. Coralogix provides the ```awsecscontainermetricsd``` receiver which enables metrics collection of all tasks on the same host. The [coralogix exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/coralogixexporter) forwards telemetry to your configured Coralogix endpoint.

The module loads the OpenTelemetry configuration from S3. The config should be generated from the **Coralogix UI AWS ECS-EC2 integration**. Alternatively, you can use the [example config from the integration chart](https://github.com/coralogix/telemetry-shippers/blob/master/otel-ecs-ec2/examples/otel-config.yaml) as a reference—note that values such as domain may differ from your setup.

The module passes these environment variables to the collector:
- `CORALOGIX_DOMAIN` – region-specific domain (from coralogix_region)
- `CORALOGIX_PRIVATE_KEY` – your API key
- `MY_POD_IP` – set to `0.0.0.0` for health check endpoint

### Service-only mode

When `task_definition_arn` is set, the module operates in **service-only mode**: it creates only the ECS service and does not manage config, command, or IAM. Task-definition concerns (S3 config, API key, roles) are ignored.

**Required:** `task_execution_role_arn` and `task_role_arn` must be explicitly null in service-only mode. Roles are defined on the task definition; the service does not accept role ARNs. If you pass non-null values, Terraform will fail validation with a clear error.

```hcl
# Service-only mode example
module "ecs-ec2" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name     = "my-cluster"
  task_definition_arn  = "arn:aws:ecs:region:account:task-definition/name:revision"
  task_execution_role_arn = null  # required
  task_role_arn        = null     # required
}
```

**Migrating from full mode to service-only:** When switching from full mode (module creates task definition and IAM roles) to service-only mode, Terraform will plan to destroy the auto-created IAM roles. The existing task definition still references those roles—if they are destroyed, ECS cannot start new tasks. Before applying, remove the task definition and IAM roles from Terraform state so they remain in AWS:

```bash
terraform state rm 'module.ecs_ec2.aws_ecs_task_definition.coralogix_otel_agent[0]'
terraform state rm 'module.ecs_ec2.aws_iam_role.otel_task_execution_role_s3[0]'
terraform state rm 'module.ecs_ec2.aws_iam_role.otel_task_role_s3[0]'
# Plus any attached policies (aws_iam_role_policy.*, aws_iam_role_policy_attachment.*)
```

Then apply with `task_definition_arn` set. The service will continue using the existing task definition and roles.

## Usage

```terraform
module "ecs-ec2" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name  = "my-cluster"
  image_version     = "v0.5.10"
  coralogix_region  = "EU1"
  api_key           = "your-coralogix-api-key"
  s3_config_bucket  = "my-otel-config-bucket"
  s3_config_key     = "configs/otel-config.yaml"

  health_check_enabled = true
}
```

## Health Checks

ECS container health checks can be enabled to monitor the OTEL collector's health status. Health checks use the `/healthcheck` binary that is available in OTEL collector versions v0.4.2 and later.

You can control health checks using:
- `health_check_enabled`: Enable/disable ECS container health checks
- `health_check_interval`: Health check interval in seconds (default: 30)
- `health_check_timeout`: Health check timeout in seconds (default: 5)
- `health_check_retries`: Number of health check retries (default: 3)
- `health_check_start_period`: Health check start period in seconds (default: 10)

**Note:** Health checks require OTEL collector image version v0.4.2 or later, as the `/healthcheck` binary was added in that version.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws | >= 6.0 |
| random | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecs_cluster_name | Name of the AWS ECS Cluster | `string` | n/a | yes |
| image_version | Coralogix OTEL Collector image version/tag | `string` | `null` | yes* |
| coralogix_region | Coralogix region: EU1, EU2, AP1, AP2, AP3, US1, US2, custom | `string` | `null` | yes* |
| api_key | Send-Your-Data API key | `string` | `null` | yes** |
| s3_config_bucket | S3 bucket containing the OTEL config | `string` | `null` | yes* |
| s3_config_key | S3 object key for the config file | `string` | `null` | yes* |
| config_source | Reserved for UI compatibility. Only 's3' supported. | `string` | `"s3"` | no |
| image | OTEL Collector image | `string` | `"coralogixrepo/coralogix-otel-collector"` | no |
| memory | Task memory (MiB) | `number` | `256` | no |
| custom_domain | Custom Coralogix domain (e.g. Private Link) | `string` | `null` | no |
| use_api_key_secret | Use API key from Secrets Manager | `bool` | `false` | no |
| api_key_secret_arn | ARN of Secrets Manager secret | `string` | `null` | no |
| task_execution_role_arn | Custom execution role. When null, module auto-creates one (S3 + optional Secrets Manager). Must be null in service-only mode. | `string` | `null` | no |
| task_role_arn | Custom task role. When null, module auto-creates one with S3 read. Must be null in service-only mode. | `string` | `null` | no |
| health_check_enabled | Enable ECS container health check | `bool` | `false` | no |
| health_check_interval | Health check interval (seconds) | `number` | `30` | no |
| health_check_timeout | Health check timeout (seconds) | `number` | `5` | no |
| health_check_retries | Health check retries | `number` | `3` | no |
| health_check_start_period | Health check start period (seconds) | `number` | `10` | no |
| tags | Resource tags | `map(string)` | `null` | no |
| task_definition_arn | Existing task definition ARN. When set, service-only mode: module creates only the ECS service; S3/roles ignored; task_execution_role_arn and task_role_arn must be null. | `string` | `null` | no |

\* Required when `task_definition_arn` is null (module creates the task definition). Ignored in service-only mode.

\** Required unless `use_api_key_secret` is true (when module creates the task definition).

### Common validation errors

| Error | Cause | Fix |
|-------|-------|-----|
| `task_execution_role_arn must be null in service-only mode` | You set `task_definition_arn` but left `task_execution_role_arn` non-null. | Set `task_execution_role_arn = null` and `task_role_arn = null` when using `task_definition_arn`. |
| `task_role_arn must be null in service-only mode` | Same as above for task role. | Same fix. |

## Outputs

| Name | Description |
|------|-------------|
| coralogix_otel_agent_service_id | ID of the ECS Service |
| coralogix_otel_agent_task_definition_arn | ARN of the ECS Task Definition |
