# Coralogix OpenTelemetry Agent for ECS-EC2

This example demonstrates how to deploy the Coralogix OpenTelemetry Agent as a Daemon Service in an ECS cluster running on EC2 instances.

## Overview

The Coralogix OpenTelemetry Agent is deployed as a Daemon ECS Task, meaning one OTEL collector agent container runs on each EC2 instance across the cluster. This provides comprehensive telemetry collection for all applications running in your ECS cluster.

## Features

- **Head Sampling**: Configurable sampling with proportional, equalizing, or hash_seed modes
- **Span Metrics**: Automatic generation of metrics from traces
- **Database Traces**: Detailed database operation metrics (optional)
- **Health Checks**: ECS container health monitoring (v0.4.2+)
- **Multiple Configuration Sources**: Template, S3, or Parameter Store
- **API Key Management**: Direct configuration or AWS Secrets Manager integration
- **Flexible Execution Roles**: Auto-created or custom IAM roles

## Quick Start

```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"
  
  # Required parameters
  ecs_cluster_name         = "your-ecs-cluster-name"
  image_version            = "v0.4.2"
  coralogix_region         = "EU1"
  default_application_name = "MyApplication"
  default_subsystem_name   = "ECS-EC2"
  api_key                  = "your-coralogix-api-key"
  
  # Optional parameters with sensible defaults
  enable_head_sampler      = true
  sampling_percentage      = 10
  sampler_mode            = "proportional"
  enable_span_metrics     = true
  enable_traces_db        = false
  health_check_enabled    = true
}
```

## Configuration Examples

### Template Configuration (Default)
```hcl
module "ecs-ec2" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"
  
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  memory                   = 2048
  coralogix_region         = "EU1"
  default_application_name = "MyApp"
  default_subsystem_name   = "ECS-EC2"
  api_key                  = "your-api-key"
  
  # Sampling configuration
  enable_head_sampler      = true
  sampling_percentage      = 25
  sampler_mode            = "proportional"
  
  # Features
  enable_span_metrics      = true
  enable_traces_db         = true
  
  # Health checks
  health_check_enabled     = true
  health_check_interval    = 30
  health_check_timeout     = 5
  health_check_retries     = 3
}
```

### S3 Configuration
```hcl
module "ecs-ec2-s3" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"
  
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  memory                   = 2048
  coralogix_region         = "EU1"
  default_application_name = "MyApp"
  default_subsystem_name   = "ECS-EC2"
  api_key                  = "your-api-key"
  
  # S3 Configuration
  config_source            = "s3"
  s3_config_bucket         = "my-otel-config-bucket"
  s3_config_key            = "configs/otel-config.yaml"
  
  # Optional: Custom execution role (auto-created if not provided)
  task_execution_role_arn  = "arn:aws:iam::123456789012:role/my-custom-role"
}
```

### Parameter Store Configuration
```hcl
module "ecs-ec2-parameter-store" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"
  
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  memory                   = 2048
  coralogix_region         = "EU1"
  default_application_name = "MyApp"
  default_subsystem_name   = "ECS-EC2"
  api_key                  = "your-api-key"
  
  # Parameter Store Configuration
  config_source                    = "parameter-store"
  custom_config_parameter_store_name = "/my-app/otel-config"
  
  # Required: Custom execution role for parameter store access
  task_execution_role_arn          = "arn:aws:iam::123456789012:role/my-custom-role"
}
```

### Using Secrets Manager for API Key
```hcl
module "ecs-ec2-secrets" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"
  
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  memory                   = 2048
  coralogix_region         = "EU1"
  default_application_name = "MyApp"
  default_subsystem_name   = "ECS-EC2"
  
  # Secrets Manager Configuration
  use_api_key_secret       = true
  api_key_secret_arn       = "arn:aws:secretsmanager:region:account:secret:name"
  task_execution_role_arn  = "arn:aws:iam::123456789012:role/my-custom-role"
}
```

## Usage

1. Update the following variables in `ecs-ec2.tf`:
   - `ecs_cluster_name`: Your ECS cluster name
   - `coralogix_region`: Your Coralogix region (EU1, EU2, AP1, AP2, AP3, US1, US2, custom)
   - `default_application_name`: Your application name
   - `default_subsystem_name`: Your subsystem name
   - `api_key`: Your Coralogix API key

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration Sources

### Template Configuration (Default)
Uses built-in template configuration with customizable sampling and feature flags. The appropriate configuration file is automatically selected based on your feature requirements.

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

## Execution Role Management

The module provides flexible execution role management:

- **Template Configuration**: No execution role required
- **S3 Configuration**: Auto-created role with S3 permissions (if no custom role provided)
- **Parameter Store Configuration**: Custom execution role required
- **Secrets Manager**: Custom execution role required

Users can always override with their own execution role for any configuration source.


## Quick Start

To setup:
```bash
terraform init && terraform plan && terraform apply -auto-approve
```

To tear-down:
```bash
terraform destroy
```
