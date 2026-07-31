# Coralogix OpenTelemetry Agent for ECS-EC2

This example demonstrates how to deploy the Coralogix OpenTelemetry Agent as a Daemon Service in an ECS cluster running on EC2 instances.

## Usage

Save this code in a Terraform file and change the values according to your settings.

**Note**: When using collector mode, ensure you have uploaded the required OpenTelemetry configuration to your S3 bucket before deploying. The config should be generated from the **Coralogix UI AWS ECS-EC2 integration**. Alternatively, you can use the [example config from the integration chart](https://github.com/coralogix/telemetry-shippers/blob/master/otel-ecs-ec2/examples/otel-config.yaml) as a reference—note that values such as domain may differ from your setup.

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

### Supervisor with Embedded Configurations

Supervisor mode uses the supervised image and embeds the default Supervisor and Collector configurations when no S3 paths are provided.

```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name   = "my-ecs-cluster"
  supervisor_enabled = true
  coralogix_region   = "EU1"
  api_key            = "your-coralogix-api-key"
}
```

### Supervisor with Initial Fallback Configurations

When OpAMP remote config is unavailable, the Supervisor can fall back to collector configs hosted in S3. Provide full `s3://` object URLs and set `s3_config_bucket` so the auto-created task role can read them. This applies only to the embedded Supervisor config.

```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name   = "my-ecs-cluster"
  supervisor_enabled = true
  coralogix_region   = "EU1"
  api_key            = "your-coralogix-api-key"

  s3_config_bucket = "my-otel-config-bucket"
  initial_fallback_configs = [
    "s3://my-otel-config-bucket.s3.eu-north-1.amazonaws.com/<ACCOUNT_ID>/<GROUP_NAME>/<COLLECTOR_VERSION>/<REMOTE_CONFIG_NAME>/config.yaml",
    "s3://my-otel-config-bucket.s3.eu-north-1.amazonaws.com/<ACCOUNT_ID>/<GROUP_NAME>/EMPTY_VERSION/<REMOTE_CONFIG_NAME>/config.yaml",
  ]
}
```

### Profiling in Collector Mode

Upload the included [`profiling-config.yaml`](./profiling-config.yaml) file to S3. Set `profiling_s3_config_key` to its object key.

```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name  = "my-ecs-cluster"
  image_version     = "v0.5.10"
  coralogix_region  = "EU1"
  api_key           = "your-coralogix-api-key"
  s3_config_bucket  = "my-otel-config-bucket"
  s3_config_key     = "configs/otel-config.yaml"

  profiling_enabled          = true
  profiling_s3_config_bucket = "my-otel-config-bucket"
  profiling_s3_config_key    = "configs/profiling-config.yaml"
}
```

### Profiling in Supervisor Mode

The profiling Supervisor starts with a NOP configuration. After deployment, assign the included [`profiling-config.yaml`](./profiling-config.yaml) file to the profiling agent through Coralogix remote configuration.

```hcl
module "otel_ecs_ec2_coralogix" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2"

  ecs_cluster_name   = "my-ecs-cluster"
  supervisor_enabled = true
  coralogix_region   = "EU1"
  api_key            = "your-coralogix-api-key"
  profiling_enabled  = true
}
```

### Using Secrets Manager for API Key

The module auto-creates an execution role with the standard ECS execution policy and Secrets Manager access when `task_execution_role_arn` is not provided. Runtime S3 access is granted through the task role:

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

**Note**: When providing a custom `task_role_arn`, ensure it has `s3:GetObject`, `s3:GetObjectVersion`, and `s3:ListBucket` permissions for the configuration bucket, as the config-loader container accesses S3 at runtime. When profiling uses a separate S3 bucket, grant the same permissions for that bucket as well.

## IAM Role Management

The module separates execution roles and task roles for better security following the principle of least privilege:

### Execution Role
Used by ECS for infrastructure operations (pulling images, retrieving secrets, etc.):
- **Auto-created Role**: Created with the standard ECS task execution policy
- **Custom Role**: Users can provide their own execution role via `task_execution_role_arn`
- **Secrets Manager**: The module adds secret access to the auto-created role when `use_api_key_secret` is true

### Task Role
Used by the running container at runtime for AWS API access:
- **Auto-created Role**: A minimal task role with S3 read permissions is created when an S3 config is selected and no custom `task_role_arn` is provided
- **Custom Role**: Users can provide their own task role via `task_role_arn` for additional AWS service access if needed

## Quick Start

```bash
terraform init
terraform plan
terraform apply
```

Run `terraform destroy` when you don't need these resources.
