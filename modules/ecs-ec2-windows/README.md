# Coralogix OpenTelemetry Agent for ECS EC2 (Windows). Terraform module.

Terraform module to deploy the Coralogix Distribution for Open Telemetry (CDOT) as a **Daemon** ECS service on an **existing** AWS ECS Cluster with **Windows EC2** container instances. The integration matches the [ecs-ec2-windows telemetry shipper](https://github.com/coralogix/telemetry-shippers/tree/main/otel-ecs-ec2-windows): same OTEL config (Windows-optimized, ECS Task Metadata, no Docker API), same collector image and feature gates. Clients run this as a Terraform module without using Make or Helm.

The agent runs one task per Windows EC2 instance, uses **awsvpc** network mode, mounts `C:\` and `C:\ProgramData\Amazon\ECS` for ECS metadata, and sends logs to CloudWatch via **awslogs**. The built-in config supports OTLP, Jaeger, Zipkin, StatsD, Prometheus scrape, ECS container metrics (sidecar mode), span metrics, and the Coralogix exporter.

## Requirements

- Existing ECS cluster with **Windows** EC2 capacity (e.g. `WINDOWS_SERVER_2022_CORE`).
- Subnets and security groups where the Daemon service will run (private subnets recommended; outbound allowed for Coralogix and optional S3/Secrets).

## Comparison: ecs-ec2 (Linux) vs ecs-ec2-windows

How this module differs from the Linux agent module [ecs-ec2](../ecs-ec2):

### Terraform / infrastructure

| Aspect | ecs-ec2 (Linux) | ecs-ec2-windows |
|--------|------------------|------------------|
| **OS / cluster** | Amazon Linux 2 (EC2 ECS-optimized) | Windows Server 2022 Core (EC2 ECS-optimized) |
| **Network mode** | `host` (agent shares instance network) | `awsvpc` (agent gets its own ENI) |
| **Subnets / security groups** | Not required (host mode); optional for application tasks | Required (`subnet_ids`, `security_group_ids`) |
| **Agent task** | Privileged; host mounts (`/var/lib/docker`, `/var/run/docker.sock`) | Not privileged; mounts `C:\`, `C:\ProgramData\Amazon\ECS` |
| **Agent image** | Linux tags (e.g. `v0.5.0`) | Windows tags (e.g. `v0.5.10-windowsserver-2022`) |
| **Service discovery** | — | Optional `service_discovery_registry_arn` so other tasks reach agent via DNS (e.g. `agent.otel.local:4317`) |
| **Logging** | `json-file` (host) | `awslogs` (CloudWatch); module can create log group |
| **Task execution role** | Created only when using S3, Parameter Store, or Secrets Manager | Always required (ECR, CloudWatch Logs); created by module if not provided |

### OTEL config (template)

| Aspect | ecs-ec2 (Linux) | ecs-ec2-windows |
|--------|------------------|------------------|
| **Logs receivers** | `filelog` (Docker container logs under `/hostfs/var/lib/docker/containers/`) + `otlp` | `otlp` only (no filelog; Windows containers don’t expose logs as host files) |
| **Logs pipeline** | `filelog` + `otlp` → `ecsattributes/container-logs` | `otlp` only; `ecsattributes/container-logs` disabled (no Docker daemon on Windows) |
| **ECS container metrics** | `awsecscontainermetricsd` (daemon: Docker API + ECS metadata) | `awsecscontainermetricsd` with **`sidecar: true`** (ECS Task Metadata only) |
| **hostmetrics** | `root_path: /` (Linux paths); Linux-specific exclusions | No `root_path`; Windows-specific filesystem exclusions |
| **resourcedetection** | `system` + `env` (host.id from OS) | `env` only (system detector fails in Windows container); `host.id` from ec2 detector |
| **opamp** | Enabled (Fleet Management) | Disabled (extension fails on Windows container) |
| **Agent feature gate** | Not set | `--feature-gates=service.profilesSupport` |
| **Health check** | `/healthcheck` binary | `CMD /C exit 0` (Windows) |

## Usage

```hcl
# Deploy OTEL agent Daemon on an existing Windows ECS cluster (template config)
module "ecs_ec2_windows" {
  source               = "coralogix/aws/coralogix//modules/ecs-ec2-windows"
  ecs_cluster_name     = "my-windows-ecs-cluster"
  subnet_ids           = ["subnet-xxx", "subnet-yyy"]
  security_group_ids   = ["sg-xxx"]
  image_version        = "v0.5.10-windowsserver-2022"  # Windows image tag
  coralogix_region     = "EU2"
  api_key              = "cxtp_YourSendYourDataAPIKey"

  # Optional
  default_application_name = "otel"
  default_subsystem_name   = "ecs-ec2-windows"
  cpu                      = 1024
  memory                   = 2048
  health_check_enabled     = true
}

# With API key from Secrets Manager
module "ecs_ec2_windows_secret" {
  source                 = "coralogix/aws/coralogix//modules/ecs-ec2-windows"
  ecs_cluster_name       = "my-windows-ecs-cluster"
  subnet_ids             = ["subnet-xxx", "subnet-yyy"]
  security_group_ids     = ["sg-xxx"]
  image_version          = "v0.5.10-windowsserver-2022"
  coralogix_region       = "EU2"
  use_api_key_secret     = true
  api_key_secret_arn     = "arn:aws:secretsmanager:..."
  task_execution_role_arn = "arn:aws:iam::..."  # must have ECR + logs + secrets access
}

# Config from S3
module "ecs_ec2_windows_s3" {
  source               = "coralogix/aws/coralogix//modules/ecs-ec2-windows"
  ecs_cluster_name     = "my-windows-ecs-cluster"
  subnet_ids           = ["subnet-xxx", "subnet-yyy"]
  security_group_ids   = ["sg-xxx"]
  image_version        = "v0.5.10-windowsserver-2022"
  coralogix_region     = "EU2"
  api_key              = "cxtp_..."
  config_source        = "s3"
  s3_config_bucket     = "my-otel-config-bucket"
  s3_config_key        = "configs/otel-config.yaml"
}
```

## Configuration sources

- **template** (default): Uses the module’s Windows OTEL config template (same behavior as the telemetry-shippers Windows integration). Domain, application name, and subsystem name are set via variables; API key via env or secret.
- **s3**: Load config from S3 at runtime. Provide `s3_config_bucket` and `s3_config_key`. The module can create a task execution role and task role with S3 read, or you can supply your own.
- **parameter-store**: Load config from SSM Parameter Store. Provide `custom_config_parameter_store_name` and a `task_execution_role_arn` with Parameter Store read access.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecs_cluster_name | Name of the existing Windows ECS cluster | `string` | n/a | yes |
| subnet_ids | Subnet IDs for the ECS service (awsvpc) | `list(string)` | n/a | yes |
| security_group_ids | Security group IDs for the ECS service | `list(string)` | n/a | yes |
| service_discovery_registry_arn | Cloud Map service ARN; when set, the agent registers so other tasks can reach it via DNS (agent.otel.local:4317) | `string` | `null` | no |
| image_version | OTEL Collector image tag (use a Windows tag, e.g. v0.5.10-windowsserver-2022) | `string` | n/a | yes |
| coralogix_region | Coralogix region (EU1, EU2, AP1, AP2, AP3, US1, US2, custom) | `string` | n/a | yes |
| api_key | Send-Your-Data API key (required unless use_api_key_secret is true) | `string` | `null` | no |
| use_api_key_secret | Use API key from Secrets Manager | `bool` | `false` | no |
| api_key_secret_arn | ARN of the secret (required if use_api_key_secret is true) | `string` | `null` | no |
| task_execution_role_arn | Task execution role (ECR, logs, optional S3/secrets). If null, a role with ECR + CloudWatch Logs is created | `string` | `null` | no |
| task_role_arn | Task role for runtime (e.g. S3 config). If null and config_source=s3, a role with S3 read is created | `string` | `null` | no |
| config_source | Config source: template, s3, parameter-store | `string` | `"template"` | no |
| s3_config_bucket | S3 bucket for config (required when config_source=s3) | `string` | `null` | no |
| s3_config_key | S3 key for config (required when config_source=s3) | `string` | `null` | no |
| custom_config_parameter_store_name | Parameter Store name (required when config_source=parameter-store) | `string` | `null` | no |
| custom_domain | Override Coralogix domain (e.g. private link) | `string` | `null` | no |
| default_application_name | Default Coralogix application name | `string` | `"otel"` | no |
| default_subsystem_name | Default Coralogix subsystem name | `string` | `"ecs-ec2"` | no |
| image | OTEL Collector image repository | `string` | `"coralogixrepo/coralogix-otel-collector"` | no |
| cpu | Task CPU units (1024 = 1 vCPU) | `number` | `1024` | no |
| memory | Task memory (MiB) | `number` | `2048` | no |
| cloudwatch_log_group_name | CloudWatch log group name; if null, one is created | `string` | `null` | no |
| cloudwatch_log_retention_days | Retention for the created log group | `number` | `7` | no |
| health_check_enabled | Enable container health check (Windows: CMD /C exit 0) | `bool` | `false` | no |
| health_check_interval | Health check interval (seconds) | `number` | `30` | no |
| health_check_timeout | Health check timeout (seconds) | `number` | `5` | no |
| health_check_retries | Health check retries | `number` | `3` | no |
| health_check_start_period | Health check start period (seconds) | `number` | `10` | no |
| enable_head_sampler | Enable head sampling (template config) | `bool` | `true` | no |
| sampler_mode | Sampler mode (template config) | `string` | `"proportional"` | no |
| sampling_percentage | Sampling percentage (template config) | `number` | `10` | no |
| enable_span_metrics | Enable span metrics (template config) | `bool` | `true` | no |
| enable_traces_db | Enable DB traces (template config) | `bool` | `false` | no |
| task_definition_arn | Use existing task definition ARN instead of creating one | `string` | `null` | no |
| tags | Resource tags | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| coralogix_otel_agent_service_id | ECS service ID of the OTEL agent Daemon |
| coralogix_otel_agent_task_definition_arn | Task definition ARN of the OTEL agent |
| cloudwatch_log_group_name | CloudWatch log group name used by the agent |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9.0 |
| aws | >= 6.0 |
| random | >= 3.0 |

## Service discovery

To have other tasks in the same VPC reach the agent via DNS (`agent.otel.local:4317`), the agent ECS service must register with the same AWS Cloud Map service. In the [telemetry-shippers otel-ecs-ec2-windows](https://github.com/coralogix/telemetry-shippers/tree/main/otel-ecs-ec2-windows) stack, that service is created (namespace `otel.local`, service `agent`). Pass its ARN into the module:

```hcl
service_discovery_registry_arn = "arn:aws:servicediscovery:REGION:ACCOUNT:service/srv-xxxx"
```

Get the ARN from the telemetry-shippers stack: `terraform -chdir=path/to/telemetry-shippers/otel-ecs-ec2-windows/terraform output -raw service_discovery_agent_arn`. Ensure the agent runs in the same VPC and security group (or one that allows TCP 4317 from those tasks) so discovery and connectivity work.

## Notes

- The module does **not** create the ECS cluster, launch template, or ASG. Use an existing Windows ECS cluster (e.g. created separately or via the [telemetry-shippers terraform root](https://github.com/coralogix/telemetry-shippers/tree/main/otel-ecs-ec2-windows/terraform) for reference).
- Windows image tags are distinct from Linux; use a tag such as `v0.5.10-windowsserver-2022` from [Docker Hub](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector/tags).
- Built-in template config matches the telemetry-shippers Windows integration (awsecscontainermetricsd sidecar, resourcedetection env+ec2, health_check endpoint from MY_POD_IP, no Docker/opamp on Windows).
