# OTEL Collector agent on ECS/EC2

## Usage

To run this example you need to save this code in Terraform file, and change the values according to your settings.

For parameter details, see [ECS EC2 module README](../../modules/ecs-ec2/README.md)

For test sample, see [ECS EC2 tests README](../../tests/ecs-ec2/README.md)

```hcl
module "otel_ecs_ec2_coralogix" {
  source                   = "coralogix/aws/coralogix//modules/ecs-ec2"
  ecs_cluster_name         = "test-lab-cluster"
  image_version            = "v0.3.1"
  memory                   = 256
  coralogix_region         = "EU1"
  custom_domain            = null
  default_application_name = "YOUR_APPLICATION_NAME"
  default_subsystem_name   = "YOUR_SUBSYSTEM_NAME"
  api_key                  = "1234567890_DUMMY_API_KEY"
  otel_config_file         = "./otel_config.tftpl.yaml"
}
```

To setup:
```bash
terraform init && terraform plan && time terraform apply -auto-approve
```

To tear-down:
```bash
terraform destroy
```

Please observe cost-optimization practices.
