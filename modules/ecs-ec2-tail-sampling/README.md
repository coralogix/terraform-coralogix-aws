# ECS EC2 Tail Sampling Module

This Terraform module deploys OpenTelemetry Collector components for tail sampling on AWS ECS EC2 clusters. It supports two deployment types:

- **Tail Sampling**: Deploys agent (daemon) and gateway services for distributed tail sampling
- **Central Cluster**: Deploys receiver and gateway services for centralized telemetry collection

## Features

- **S3-Only Configuration**: All OpenTelemetry configurations must be stored in S3
- **External IAM Role Support**: Can use existing task execution roles or create new ones
- **Custom Image Support**: Use Coralogix image with version or custom images from any registry
- **Service Discovery**: Automatic CloudMap namespace and service registration
- **Health Check Support**: Optional ECS container health checks for all OpenTelemetry components
- **Conditional Resource Creation**: Only creates resources needed for the selected deployment type
- **ECS EC2 Support**: Designed for EC2 launch type, not Fargate

## Usage

### Tail Sampling Deployment

```hcl
module "otel_tail_sampling" {
  source = "../../modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "my-ecs-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "tail-sampling"
  s3_config_bucket     = "my-otel-configs"
  agent_s3_config_key  = "configs/agent-config.yaml"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  image_version        = "v0.5.0"
  coralogix_region     = "EU2"
  api_key              = "your-api-key"

  # Optional parameters
  gateway_task_count = 1
  memory            = 1024
  tags = {
    Environment = "production"
    Project     = "monitoring"
  }
}
```

### Central Cluster Deployment

```hcl
module "otel_central_cluster" {
  source = "../../modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name       = "my-ecs-cluster"
  vpc_id                = "vpc-12345678"
  subnet_ids            = ["subnet-12345678", "subnet-87654321"]
  security_group_ids    = ["sg-12345678"]
  deployment_type       = "central-cluster"
  s3_config_bucket      = "my-otel-configs"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  receiver_s3_config_key = "configs/receiver-config.yaml"
  image_version         = "v0.5.0"
  coralogix_region      = "EU2"
  api_key               = "your-api-key"

  # Optional parameters
  gateway_task_count = 1
  receiver_task_count = 2
  memory             = 1024
  tags = {
    Environment = "production"
    Project     = "monitoring"
  }
}
```

### Using External IAM Role

```hcl
module "otel_tail_sampling" {
  source = "../../modules/ecs-ec2-tail-sampling"

  # ... other parameters ...

  # Use existing IAM role
  task_execution_role_arn = "arn:aws:iam::123456789012:role/my-existing-ecs-task-execution-role"
}
```

### Using Custom Images

You can use either a Coralogix image with version or a custom image:

**Using Coralogix Image with Version:**
```hcl
module "otel_tail_sampling" {
  source = "../../modules/ecs-ec2-tail-sampling"

  # ... other parameters ...
  
  # Coralogix image with version
  image_version = "v0.5.0"
  custom_image  = null  # or omit this line
}
```

**Using Custom Image:**
```hcl
module "otel_tail_sampling" {
  source = "../../modules/ecs-ec2-tail-sampling"

  # ... other parameters ...
  
  # Custom image (overrides image_version)
  custom_image = "my-registry.com/custom-otel-collector:latest"
}
```

### Enabling Health Checks

Health checks can be enabled for all OpenTelemetry containers (requires OTEL collector image version v0.4.2 or later):

```hcl
module "otel_tail_sampling" {
  source = "../../modules/ecs-ec2-tail-sampling"

  # ... other parameters ...
  
  # Enable health checks with custom settings
  health_check_enabled      = true
  health_check_interval     = 30    # seconds
  health_check_timeout      = 5     # seconds
  health_check_retries      = 3     # attempts
  health_check_start_period = 10    # seconds
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecs_cluster_name | Name of the AWS ECS Cluster to deploy the Coralogix OTEL Collector | `string` | n/a | yes |
| vpc_id | VPC ID for CloudMap namespace and ECS services | `string` | n/a | yes |
| subnet_ids | List of subnet IDs for ECS services | `list(string)` | n/a | yes |
| security_group_ids | List of security group IDs for ECS services | `list(string)` | n/a | yes |
| deployment_type | Deployment type: 'tail-sampling' or 'central-cluster' | `string` | n/a | yes |
| s3_config_bucket | S3 bucket name containing the configuration files | `string` | n/a | yes |
| agent_s3_config_key | S3 object key for the Agent configuration file (required for tail-sampling deployment) | `string` | `null` | no |
| gateway_s3_config_key | S3 object key for the Gateway configuration file | `string` | n/a | yes |
| receiver_s3_config_key | S3 object key for the Receiver configuration file (required for central-cluster deployment) | `string` | `null` | no |
| image_version | The Coralogix Distribution OpenTelemetry Image Version/Tag. Required when custom_image is not provided | `string` | `null` | no |
| custom_image | Custom OpenTelemetry Collector Image to use (e.g., 'my-registry.com/custom-otel-collector:latest'). If provided, this overrides image_version | `string` | `null` | no |
| coralogix_region | The region of the Coralogix endpoint domain | `string` | n/a | yes |
| api_key | The Send-Your-Data API key for your Coralogix account | `string` | n/a | yes |
| task_execution_role_arn | External IAM role ARN for task execution | `string` | `null` | no |
| gateway_task_count | Number of Gateway tasks to run | `number` | `1` | no |
| receiver_task_count | Number of Receiver tasks to run (only for central-cluster deployment) | `number` | `2` | no |
| memory | The amount of memory (in MiB) used by the task | `number` | `1024` | no |
| custom_domain | Coralogix custom domain | `string` | `null` | no |
| default_application_name | The default Coralogix Application name | `string` | `"OTEL"` | no |
| default_subsystem_name | The default Coralogix Subsystem name | `string` | `"ECS-EC2"` | no |
| health_check_enabled | Enable ECS container health check for OTEL containers. Requires OTEL collector image version v0.4.2 or later | `bool` | `false` | no |
| health_check_interval | Health check interval in seconds. Only used if health_check_enabled is true | `number` | `30` | no |
| health_check_timeout | Health check timeout in seconds. Only used if health_check_enabled is true | `number` | `5` | no |
| health_check_retries | Health check retries. Only used if health_check_enabled is true | `number` | `3` | no |
| health_check_start_period | Health check start period in seconds. Only used if health_check_enabled is true | `number` | `10` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudmap_namespace_id | ID of the CloudMap namespace |
| cloudmap_namespace_name | Name of the CloudMap namespace |
| gateway_service_id | ID of the Gateway CloudMap service |
| gateway_service_arn | ARN of the Gateway CloudMap service |
| receiver_service_id | ID of the Receiver CloudMap service (only for central-cluster deployment) |
| receiver_service_arn | ARN of the Receiver CloudMap service (only for central-cluster deployment) |
| task_execution_role_arn | ARN of the task execution role (either created or provided) |
| task_execution_role_name | Name of the task execution role (only if created by module) |
| agent_task_definition_arn | ARN of the Agent task definition (only for tail-sampling deployment) |
| gateway_task_definition_arn | ARN of the Gateway task definition |
| receiver_task_definition_arn | ARN of the Receiver task definition (only for central-cluster deployment) |
| agent_service_name | Name of the Agent ECS service (only for tail-sampling deployment) |
| gateway_service_name | Name of the Gateway ECS service |
| receiver_service_name | Name of the Receiver ECS service (only for central-cluster deployment) |
| deployment_type | The deployment type that was used |

## Architecture

### Tail Sampling Deployment
- **Agent Service**: Daemon service running on each EC2 instance
  - Collects telemetry data from applications
  - Sends spans to gateway for tail sampling decisions
- **Gateway Service**: Replica service for tail sampling
  - Receives spans from agents
  - Performs tail sampling decisions
  - Sends sampled data to Coralogix

### Central Cluster Deployment
- **Receiver Service**: Replica service for telemetry collection
  - Receives OTLP data from external sources
  - Sends metrics and logs directly to Coralogix
  - Load balances spans to gateway
- **Gateway Service**: Replica service for tail sampling
  - Receives spans from receiver
  - Performs tail sampling decisions
  - Sends sampled data to Coralogix

## IAM Permissions

The module creates or uses a task execution role with the following permissions:

- **ECS Task Execution**: Standard ECS task execution permissions
- **S3 Read Access**: Read access to the specified S3 bucket for configuration files
- **CloudMap Discovery**: Service discovery permissions for load balancing

## Service Discovery

The module automatically creates:
- CloudMap namespace: `cx-otel`
- Gateway service: `grpc-gateway`
- Receiver service: `grpc-receiver` (only for central cluster)

Services can be discovered using DNS names:
- Gateway: `grpc-gateway.cx-otel`
- Receiver: `grpc-receiver.cx-otel`

## Notes

- This module is designed for ECS EC2 launch type only
- All configurations must be stored in S3
- The agent service uses host network mode for container access
- Gateway and receiver services use awsvpc network mode
- Docker socket access is required for the agent service
- Either `image_version` or `custom_image` must be provided, but not both
- When using `custom_image`, the `image_version` parameter is ignored
- Health checks require OTEL collector image version v0.4.2 or later and use the `/healthcheck` endpoint
