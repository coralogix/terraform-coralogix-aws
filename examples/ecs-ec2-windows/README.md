# Coralogix OpenTelemetry Agent for ECS EC2 (Windows)

This example deploys the Coralogix OTEL agent as a **Daemon** ECS service on an **existing** Windows ECS cluster (EC2, `WINDOWS_SERVER_2022_CORE`). The agent uses the same Windows-optimized config as the [ecs-ec2-windows telemetry shipper](https://github.com/coralogix/telemetry-shippers/tree/main/otel-ecs-ec2-windows)—no Make or Helm required.

## Prerequisites

- An existing ECS cluster with **Windows** EC2 capacity (e.g. Windows Server 2022 Core).
- Subnets and security groups where the Daemon service will run (typically private subnets with outbound allowed).

## Quick start

The example uses a local module source so it runs from this repo without the registry. For published use, switch to `source = "coralogix/aws/coralogix//modules/ecs-ec2-windows"`.

1. Copy and set variables (e.g. in `terraform.tfvars` or CLI):

   ```hcl
   ecs_cluster_name   = "my-windows-ecs-cluster"
   subnet_ids         = ["subnet-xxx", "subnet-yyy"]
   security_group_ids  = ["sg-xxx"]
   image_version      = "v0.5.10-windowsserver-2022"
   coralogix_region   = "EU2"
   api_key            = "cxtp_YourSendYourDataAPIKey"
   ```

2. Initialize and apply:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Example usage

```hcl
module "otel_ecs_ec2_windows_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-windows"

  ecs_cluster_name   = "my-windows-ecs-cluster"
  subnet_ids         = ["subnet-aaa", "subnet-bbb"]
  security_group_ids = ["sg-xxx"]

  image_version    = "v0.5.10-windowsserver-2022"
  coralogix_region = "EU2"
  api_key          = "cxtp_..."

  default_application_name = "otel"
  default_subsystem_name   = "ecs-ec2-windows"
  cpu                      = 1024
  memory                   = 2048
  health_check_enabled     = true
}
```

## Outputs

- `coralogix_otel_agent_service_id` – ECS service ID of the OTEL agent Daemon
- `coralogix_otel_agent_task_definition_arn` – Task definition ARN
- `cloudwatch_log_group_name` – CloudWatch log group used by the agent

## Other tasks connectivity

If you run other tasks that use `agent.otel.local:4317` (e.g. from [telemetry-shippers/otel-ecs-ec2-windows](https://github.com/coralogix/telemetry-shippers/tree/main/otel-ecs-ec2-windows)), the agent must register with the same Cloud Map service. Set:

```bash
terraform apply -var="service_discovery_registry_arn=$(terraform -chdir=path/to/telemetry-shippers/otel-ecs-ec2-windows/terraform output -raw service_discovery_agent_arn)"
```

Or in `terraform.tfvars`: `service_discovery_registry_arn = "arn:aws:servicediscovery:..."`

## Cleanup

```bash
terraform destroy
```
