# ecs-ec2-tail-sampling

Coralogix provides a Terraform module to deploy OpenTelemetry Collector on AWS ECS EC2 with tail sampling capabilities.

## Usage

To run this example you need to save this code in Terraform file, and change the values according to your settings.

**Note**: Before deploying, ensure you have uploaded the required OpenTelemetry configuration files to your S3 bucket. Sample configuration files are available in the [CloudFormation repository](https://github.com/coralogix/cloudformation-coralogix-aws/tree/master/opentelemetry/ecs-ec2-tail-sampling/examples).

## Configuration examples

### Tail Sampling (default)
Deploys agent (daemon) and gateway services for distributed tail sampling across EC2 instances.
```bash
module "otel-ecs-ec2-tail-sampling" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "my-ecs-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "tail-sampling"
  s3_config_bucket     = "my-otel-configs-bucket"
  agent_s3_config_key  = "configs/agent-config.yaml"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  image_version        = "v0.5.1"
  coralogix_region     = "EU1"
  api_key              = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
}
```

### Central Cluster
Deploys receiver and gateway services for centralized telemetry collection from external agents.
```bash
module "otel-ecs-ec2-central-cluster" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "my-ecs-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "central-cluster"
  s3_config_bucket     = "my-otel-configs-bucket"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  receiver_s3_config_key = "configs/receiver-config.yaml"
  image_version        = "v0.5.1"
  coralogix_region     = "EU1"
  api_key              = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
}
```

### Using Custom Images
```bash
module "otel-ecs-ec2-custom-image" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "my-ecs-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "tail-sampling"
  s3_config_bucket     = "my-otel-configs-bucket"
  agent_s3_config_key  = "configs/agent-config.yaml"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  custom_image         = "my-registry.com/custom-otel-collector:latest"
  coralogix_region     = "EU1"
  api_key              = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"
}
```

### With Health Checks Enabled
```bash
module "otel-ecs-ec2-health-checks" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "my-ecs-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "tail-sampling"
  s3_config_bucket     = "my-otel-configs-bucket"
  agent_s3_config_key  = "configs/agent-config.yaml"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  image_version        = "v0.5.1"
  coralogix_region     = "EU1"
  api_key              = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"

  # Optional parameters with sensible defaults
  health_check_enabled = true
  memory              = 2048
  gateway_task_count  = 2
}
```

### Using External IAM Roles
```bash
module "otel-ecs-ec2-external-roles" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # Required parameters
  ecs_cluster_name      = "my-ecs-cluster"
  vpc_id               = "vpc-12345678"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  security_group_ids   = ["sg-12345678"]
  deployment_type      = "tail-sampling"
  s3_config_bucket     = "my-otel-configs-bucket"
  agent_s3_config_key  = "configs/agent-config.yaml"
  gateway_s3_config_key = "configs/gateway-config.yaml"
  image_version        = "v0.5.1"
  coralogix_region     = "EU1"
  api_key              = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXX"

  # Use existing execution role instead of creating new one
  task_execution_role_arn = "arn:aws:iam::123456789012:role/my-existing-ecs-task-execution-role"
  
  # Use existing task role (must have S3 read permissions for config bucket)
  task_role_arn = "arn:aws:iam::123456789012:role/my-existing-ecs-task-role"
}
```

**Note**: When providing a custom `task_role_arn`, ensure it has at minimum S3 read permissions (`s3:GetObject`, `s3:GetObjectVersion`) for the configuration bucket, as containers need to access S3 at runtime to read their configuration files.

## IAM Role Management

The module separates execution roles and task roles for better security following the principle of least privilege:

### Execution Role
Used by ECS for infrastructure operations (pulling images, retrieving secrets, etc.):
- **Auto-created Role**: Created with S3 read permissions for configuration files and CloudMap discovery permissions (if no custom role provided)
- **Custom Role**: Users can provide their own execution role via `task_execution_role_arn`

### Task Role
Used by the running container at runtime for AWS API access:
- **Auto-created Role**: A minimal task role with S3 read-only permissions is automatically created if no custom `task_role_arn` is provided. This ensures containers can access S3 configuration files at runtime while maintaining minimal permissions.
- **Custom Role**: Users can provide their own task role via `task_role_arn` for additional AWS service access if needed

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Run `terraform destroy` when you don't need these resources.