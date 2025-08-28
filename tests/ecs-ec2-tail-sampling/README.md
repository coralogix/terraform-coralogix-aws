# ECS EC2 Tail Sampling Module Tests

This directory contains comprehensive tests for the ECS EC2 Tail Sampling Terraform module using conditional deployment.

## Test Scenarios

The tests cover three main scenarios that can be deployed individually:

### 1. Tail Sampling Deployment
Tests the deployment of a tail sampling solution with:
- Agent service (daemon) for collecting telemetry
- Gateway service (replica) for tail sampling decisions

### 2. Central Cluster Deployment
Tests the deployment of a central cluster solution with:
- Agent service (daemon) for collecting telemetry
- Gateway service (replica) for tail sampling decisions
- Receiver service (replica) for external telemetry collection

### 3. External IAM Role Deployment
Tests the module's ability to use external IAM roles instead of creating new ones.

## Prerequisites

1. **AWS ECS Cluster**: An existing ECS cluster with EC2 instances
2. **S3 Bucket**: A bucket containing OpenTelemetry configuration files
3. **VPC and Subnets**: Network infrastructure for the ECS services
4. **Security Groups**: Security groups allowing necessary traffic
5. **Coralogix API Key**: A valid Coralogix Send-Your-Data API key
6. **External IAM Role** (optional): For testing external role functionality

## Configuration Files

### Required S3 Configuration Files

Before running the tests, you must upload the following configuration files to your S3 bucket:

- `configs/agent-config.yaml` - Agent configuration for collecting telemetry
- `configs/gateway-config.yaml` - Gateway configuration for tail sampling
- `configs/receiver-config.yaml` - Receiver configuration for external telemetry

### Uploading Configuration Files

You can upload these files using the AWS CLI:

```bash
# Upload agent configuration
aws s3 cp agent-config.yaml s3://your-bucket-name/configs/agent-config.yaml

# Upload gateway configuration
aws s3 cp gateway-config.yaml s3://your-bucket-name/configs/gateway-config.yaml

# Upload receiver configuration
aws s3 cp receiver-config.yaml s3://your-bucket-name/configs/receiver-config.yaml
```

Or using the AWS Console:
1. Navigate to your S3 bucket
2. Create a `configs/` folder
3. Upload each configuration file to the `configs/` folder

### Configuration File Sources

These configuration files can be found in the CloudFormation examples:
- `cloudformation-coralogix-aws/opentelemetry/ecs-ec2-tail-sampling/configs/`
- `cloudformation-coralogix-aws/opentelemetry/ecs-ec2-tail-sampling/examples/`

Make sure to update the configuration files with your specific Coralogix settings before uploading.

## Running Tests

### Setup

1. **Update the configuration**:
   Edit `terraform.tfvars` with your specific values.

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

### Running Different Test Scenarios

The tests use a `test_scenario` variable to control which deployment is active. Only one scenario runs at a time to avoid resource conflicts.

#### Tail Sampling Deployment
```bash
terraform plan -var="test_scenario=tail-sampling"
terraform apply -var="test_scenario=tail-sampling" -auto-approve
```

#### Central Cluster Deployment
```bash
terraform plan -var="test_scenario=central-cluster"
terraform apply -var="test_scenario=central-cluster" -auto-approve
```

#### External IAM Role Deployment
```bash
terraform plan -var="test_scenario=external-role"
terraform apply -var="test_scenario=external-role" -auto-approve
```

### Default Configuration

The `terraform.tfvars` file has a default `test_scenario` value. You can run:
```bash
terraform plan
terraform apply -auto-approve
```

### Viewing Outputs
```bash
terraform output
```

### Cleanup
```bash
terraform destroy -var="test_scenario=<scenario-name>" -auto-approve
```

## Test Validation

After deployment, verify that:

### Tail Sampling Deployment
- CloudMap namespace `cx-otel` is created
- Gateway service `grpc-gateway` is registered
- Agent task definition is created with host network mode
- Gateway task definition is created with awsvpc network mode
- Agent service is deployed as daemon service
- Gateway service is deployed as replica service

### Central Cluster Deployment
- CloudMap namespace `cx-otel` is created
- Gateway service `grpc-gateway` is registered
- Receiver service `grpc-receiver` is registered
- Agent task definition is created with host network mode
- Gateway task definition is created with awsvpc network mode
- Receiver task definition is created with awsvpc network mode
- Agent service is deployed as daemon service
- Gateway and Receiver services are deployed as replica services

### External IAM Role Deployment
- No IAM role is created by the module
- External role ARN is used for task execution
- All other resources are created normally

## Outputs

The tests provide conditional outputs based on the active test scenario:
- `test_scenario` - Shows which scenario is currently active
- Scenario-specific outputs (e.g., `tail_sampling_*`, `central_cluster_*`, `external_role_*`)
- `deployment_type` - Shows the deployment type used

## Benefits of Conditional Testing

- **No resource conflicts**: Only one scenario deploys at a time
- **Easy switching**: Change scenarios with a single variable
- **Clean state management**: Each scenario is isolated
- **Validation**: Built-in validation ensures only valid scenarios are used
- **No manual commenting**: No need to edit files to switch scenarios

## Notes

- Only one test scenario can be active at a time
- Each scenario uses different resource names to avoid conflicts
- The external role test requires a pre-existing IAM role with appropriate permissions
- All configurations must be stored in S3
- Tests use minimal resource counts to reduce costs
- The `test_scenario` variable validates input to prevent invalid scenarios
