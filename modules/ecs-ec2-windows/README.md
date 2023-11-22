# Demonstration/Example deployment of ECS EC2 Open Telemetry Agent for Windows

Terraform module to launch an example ECS Service illustrating the deployment of a demo Windows container application alongside an [Coralogix Opentelemetry Collector](https://hub.docker.com/r/coralogixrepo/coralogix-otel-collector) running in a sidecar Windows container to collect logs and metrics from applications within the ECS Task, and forwarding to Coralogix. The defatult sample application logs to STDOUT every second, and you can replace this example your own container application image. This example requires deployment into existing AWS ECS Cluster on EC2 Windows container instances.

This example is intended for demonstration and instructional purposes only. It should not be deployed directly into production. The example may be customized to suit the user's requirements.

## Usage

Provisions a demonstration ECS Service having 1 Task consisting of 1 example Windows application and 1 Windows OTEL Collector as a sidecar.

```hcl
module "ecs_ec2_windows_demo" {
  source            = "../../modules/ecs-ec2-windows"
  ecs_cluster_name  = "ecs-cluster-name"
  coralogix_region  = "Europe"|"Europe2"|"India"|"Singapore"|"US"|"US2"
  api_key           = var.api_key
  security_group_id = var.security_group_id
  subnet_ids        = var.subnet_ids
  application_name  = "Coralogix Application Name"
  subsystem_name    = "Coralogix Subsystem Name"
  custom_domain     = "[optional] custom Coralogix domain"
  app_image         = "[optional] User-provided demo App as a Windows container image, to demonstrate collection of console logs and metrics. If omitted, defaults to a provided sample Windows logging app."
  otel_image        = "[optional] Coralogix Open Telemetry distribution Windows image name and tag."
  otel_config_file  = "[optional] file path to custom OTEL collector config file"
}
```

#### Windows Sample Application
The default Windows sample application logs the following text every 1 second:
> "Hello from console writer. __N__"

Where __N__ is an incrementing number counter.

#### Verification
To verify successful deployment:
* Verify the logs are captured on your Coralogix logs console.
* Verify the metrics for the containers can be displayed on Coralogix Grafana.

#### Integrating the OTEL Collector into your application.

For logging to work, a Windows application should do either of the following:
1. Log to STDOUT. The OTEL Collector sidecar has been configured to collect docker container logs from the host.
2. Mount the log file volume to the OTEL Collector sidecar, and include the log location into the OTEL [filelog receiver configuration](./otel_ecs_ec2_win.config.yaml).
3. Instrument your application for OTEL, configured to export to the sidecar OTLP endpoints, which for 'awsvpc' networking, are at http://localhost:4317 and http://localhost:4318 

## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.6.0 |
| aws | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_service.demo_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.demo_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecsTaskExecutionRole](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_awslogs_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api\_key | The Send-Your-Data API key for your Coralogix account. See: https://coralogix.com/docs/send-your-data-api-key/ | `string` | n/a | yes |
| app\_image | Optional user-provided demo App as a Windows container image, to demonstrate collection of console logs and metrics. If omitted, defaults to a provided sample Windows logging app. | `string` | `""` | no |
| application\_name | Optional Application name as Coralogix metadata. | `string` | `"ECS-Windows-Demo"` | no |
| coralogix\_region | The region of the Coralogix endpoint domain: [Europe, Europe2, India, Singapore, US, US2, Custom]. If "Custom" then __custom\_domain__ parameter must be specified. | `string` | n/a | yes |
| custom\_domain | Optional Coralogix custom domain, e.g. "private.coralogix.com" Private Link domain. If specified, overrides the public domain corresponding to the __coralogix\_region__ parameter. | `string` | `null` | no |
| ecs\_cluster\_name | Name of the AWS ECS Cluster to deploy the demonstration ECS Service, consisting of 1 Coralogix OTEL Collector and 1 sample app as Windows containers in the task. Supports EC2 Windows instances only, not Fargate. | `string` | n/a | yes |
| otel\_config\_file | Optional file path to a custom opentelemetry configuration file. Defaults to an embedded configuration. | `string` | `null` | no |
| otel\_image | Optional Coralogix Open Telemetry distribution Windows image name and tag. | `string` | `"coralogixrepo/coralogix-otel-collector:0.1.0-windowsserver-1809"` | no |
| security\_group\_id | Security Group ID to deploy the ECS Service into. Must be in the same VPC as the ECS Cluster. | `string` | n/a | yes |
| subnet\_ids | List of subnet IDs to deploy the ECS Service into. Must be in the same VPC as the ECS Cluster. | `list` | n/a | yes |
| subsystem\_name | Optional Subsystem name as Coralogix metadata. | `string` | `"ECS-Windows-Demo"` | no |
