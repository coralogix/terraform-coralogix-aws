# Coralogix OpenTelemetry Agent for ECS-EC2 Example

This example demonstrates how to deploy the Coralogix OpenTelemetry Agent as a Daemon Service in an ECS cluster running on EC2 instances.

## Features 

1. **Head Sampling**
   - Enabled by default with 10% sampling rate
   - Uses proportional sampling mode
   - Configurable sampling percentage and mode (proportional, equalizing, hash_seed)

2. **Span Metrics**
   - Enabled by default
   - Automatically generates metrics from traces
   - Provides insights into application performance

3. **Database Traces**
   - Disabled by default
   - Can be enabled to collect detailed database operation metrics
   - Requires span metrics to be enabled

4. **Health Checks**
   - Only available from image v0.4.2
   - Optional ECS container health checks
   - Configurable intervals, timeouts, and retries

5. **API Key Management**
   - Direct API key configuration
   - Optional AWS Secrets Manager integration

6. **Custom Configuration**
   - Optional Parameter Store integration for custom OTEL configs

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

## Configuration Options

The example includes several optional configurations:

```hcl
# Head sampling configuration
enable_head_sampler     = true
sampler_mode           = "proportional"  # Options: proportional, equalizing, hash_seed
sampling_percentage    = 10              # Range: 0-100

# Span metrics configuration
enable_span_metrics    = true

# Database traces configuration
enable_traces_db       = false

# Health check configuration
health_check_enabled   = true
health_check_interval  = 30
health_check_timeout   = 5
health_check_retries   = 3
health_check_start_period = 10

# API key configuration
use_api_key_secret     = false
api_key                = "your-api-key"
api_key_secret_arn     = null

# Custom configuration
use_custom_config_parameter_store = false
custom_config_parameter_store_name = null
task_execution_role_arn = null

# Tags
tags = {
  Environment = "test"
  Project     = "coralogix-otel"
}
```

## Advanced Configuration Examples

### Example 1: All Features Enabled
```hcl
module "otel_ecs_ec2_coralogix" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  coralogix_region         = "EU1"
  default_application_name = "my-app"
  default_subsystem_name   = "my-subsystem"
  api_key                  = "your-api-key"
  
  enable_head_sampler      = true
  sampling_percentage      = 25
  sampler_mode            = "proportional"
  enable_span_metrics     = true
  enable_traces_db        = true
  health_check_enabled    = true
}
```

### Example 2: Minimal Configuration
```hcl
module "otel_ecs_ec2_coralogix" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  coralogix_region         = "EU1"
  default_application_name = "my-app"
  default_subsystem_name   = "my-subsystem"
  api_key                  = "your-api-key"
  
  # All other settings use defaults
}
```

### Example 3: Using Secrets Manager
```hcl
module "otel_ecs_ec2_coralogix" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = "my-cluster"
  image_version            = "v0.4.2"
  coralogix_region         = "EU1"
  default_application_name = "my-app"
  default_subsystem_name   = "my-subsystem"
  
  use_api_key_secret       = true
  api_key_secret_arn       = "arn:aws:secretsmanager:region:account:secret:name"
  task_execution_role_arn  = "arn:aws:iam::account:role/ecs-task-execution-role"
}
```

## Quick Start

To setup:
```bash
terraform init && terraform plan && terraform apply -auto-approve
```

To tear-down:
```bash
terraform destroy
```
