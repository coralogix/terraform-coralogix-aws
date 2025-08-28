# ECS EC2 Tail Sampling Example

This example demonstrates how to deploy the Coralogix OpenTelemetry Tail Sampling solution on AWS ECS EC2 using Terraform.

## Prerequisites

1. **AWS ECS Cluster**: An existing ECS cluster with EC2 instances
2. **S3 Bucket**: A bucket containing OpenTelemetry configuration files
3. **VPC and Subnets**: Network infrastructure for the ECS services
4. **Security Groups**: Security groups allowing necessary traffic
5. **Coralogix API Key**: A valid Coralogix Send-Your-Data API key

## Configuration Files

Before deploying, ensure you have the following configuration files uploaded to your S3 bucket:

### For Tail Sampling Deployment
- `configs/agent-config.yaml` - Agent configuration for collecting telemetry
- `configs/gateway-config.yaml` - Gateway configuration for tail sampling

### For Central Cluster Deployment
- `configs/receiver-config.yaml` - Receiver configuration for external telemetry
- `configs/gateway-config.yaml` - Gateway configuration for tail sampling

## Usage

### Basic Deployment

1. **Copy the example configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Update the configuration**:
   Edit `terraform.tfvars` with your specific values:
   - AWS region and ECS cluster name
   - VPC, subnet, and security group IDs
   - S3 bucket and configuration file keys
   - Coralogix region and API key

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

### Using Custom Images

You can specify a custom Docker image for the OpenTelemetry Collector using the `custom_image` variable:

```hcl
module "otel_ecs_ec2_tail_sampling" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # ... other parameters ...
  
  # Custom image configuration (overrides image_version)
  custom_image        = "my-registry.com/custom-otel-collector:latest"
  
  # ... rest of configuration ...
}
```

### Using Coralogix Image with Version

To use the standard Coralogix image with a specific version:

```hcl
module "otel_ecs_ec2_tail_sampling" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # ... other parameters ...
  
  # Coralogix image with version
  image_version       = "v0.5.0"
  custom_image        = null  # or omit this line
  
  # ... rest of configuration ...
}
```

### Using Custom Domain (Private Link)

For environments with Private Link or custom domains, set the `coralogix_region` to "custom" and provide a `custom_domain`:

```hcl
module "otel_ecs_ec2_tail_sampling" {
  source = "coralogix/aws/coralogix//modules/ecs-ec2-tail-sampling"

  # ... other parameters ...
  
  coralogix_region     = "custom"
  custom_domain        = "private.coralogix.com"
  
  # ... rest of configuration ...
}
```

## Deployment Types

### Tail Sampling Deployment (Default)
The example deploys a tail sampling solution with:
- **Agent Service**: Daemon service running on each EC2 instance
- **Gateway Service**: Replica service for tail sampling decisions

### Central Cluster Deployment
To deploy a central cluster instead, uncomment the central cluster module in `main.tf` and comment out the tail sampling module.

## Outputs

After successful deployment, you'll get outputs including:
- CloudMap namespace and service information
- Task definition ARNs
- ECS service names
- IAM role information

## Cleanup

To remove all resources:
```bash
terraform destroy
```

## Notes

- This example uses the default values for most optional parameters
- The agent service requires Docker socket access for container metadata
- All configurations must be stored in S3
- The module supports external IAM roles if needed
