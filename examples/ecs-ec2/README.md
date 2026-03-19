# Coralogix OpenTelemetry Agent for ECS-EC2

This example demonstrates how to deploy the Coralogix OpenTelemetry Agent as a Daemon Service in an ECS cluster running on EC2 instances.

## Usage

Save this code in a Terraform file and change the values according to your settings.

**Note**: Before deploying, ensure you have uploaded the required OpenTelemetry configuration to your S3 bucket. The config should be generated from the **Coralogix UI AWS ECS-EC2 integration**. Alternatively, you can use the [example config from the integration chart](https://github.com/coralogix/telemetry-shippers/blob/master/otel-ecs-ec2/examples/otel-config.yaml) as a reference—note that values such as domain may differ from your setup.

## Configuration Examples

### Basic S3 Configuration
```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name     = "my-ecs-cluster"
  image_version        = "v0.5.10"
  coralogix_region     = "EU1"
  api_key              = "your-coralogix-api-key"
  s3_config_bucket     = "my-otel-config-bucket"
  s3_config_key        = "configs/otel-config.yaml"
}
```

### With Health Checks Enabled
```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name      = "my-ecs-cluster"
  image_version         = "v0.5.10"
  coralogix_region      = "EU1"
  api_key               = "your-coralogix-api-key"
  s3_config_bucket      = "my-otel-config-bucket"
  s3_config_key         = "configs/otel-config.yaml"

  health_check_enabled  = true
  health_check_interval = 30
  health_check_timeout  = 5
  health_check_retries  = 3
  memory                = 2048
}
```

### Using Secrets Manager for API Key

The module auto-creates an execution role with S3 and Secrets Manager access when `task_execution_role_arn` is not provided:

```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name    = "my-ecs-cluster"
  image_version       = "v0.5.10"
  coralogix_region    = "EU1"
  s3_config_bucket    = "my-otel-config-bucket"
  s3_config_key       = "configs/otel-config.yaml"

  use_api_key_secret = true
  api_key_secret_arn = "arn:aws:secretsmanager:region:account:secret:name"
}
```

Or provide a custom execution role:

```hcl
  task_execution_role_arn = "arn:aws:iam::123456789012:role/my-custom-execution-role"
```

### Using Custom Domain (Private Link)
```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name     = "my-ecs-cluster"
  image_version        = "v0.5.10"
  coralogix_region     = "custom"
  custom_domain        = "private.coralogix.com"
  api_key              = "your-coralogix-api-key"
  s3_config_bucket     = "my-otel-config-bucket"
  s3_config_key        = "configs/otel-config.yaml"
}
```

### Using External IAM Roles
```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name     = "my-ecs-cluster"
  image_version        = "v0.5.10"
  coralogix_region     = "EU1"
  api_key              = "your-coralogix-api-key"
  s3_config_bucket     = "my-otel-config-bucket"
  s3_config_key        = "configs/otel-config.yaml"

  task_execution_role_arn = "arn:aws:iam::123456789012:role/my-existing-ecs-task-execution-role"
  task_role_arn           = "arn:aws:iam::123456789012:role/my-existing-ecs-task-role"
}
```

**Note**: When providing a custom `task_role_arn`, ensure it has at minimum S3 read permissions (`s3:GetObject`, `s3:GetObjectVersion`) for the configuration bucket, as containers need to access S3 at runtime to read their configuration files.

## IAM Role Management

The module separates execution roles and task roles for better security following the principle of least privilege:

### Execution Role
Used by ECS for infrastructure operations (pulling images, retrieving secrets, etc.):
- **Auto-created Role**: Created with S3 read permissions for configuration files (if no custom role provided)
- **Custom Role**: Users can provide their own execution role via `task_execution_role_arn`
- **Secrets Manager**: `task_execution_role_arn` must be provided when `use_api_key_secret` is true

### Task Role
Used by the running container at runtime for AWS API access:
- **Auto-created Role**: A minimal task role with S3 read-only permissions is automatically created if no custom `task_role_arn` is provided
- **Custom Role**: Users can provide their own task role via `task_role_arn` for additional AWS service access if needed

## Quick Start

```bash
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.
