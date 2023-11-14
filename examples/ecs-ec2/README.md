# OTEL Collector agent on ECS/EC2

## Usage

To run this example you need to save this code in Terraform file, and change the values according to your settings.

For parameter details, see [ECS EC2 module README](../../modules/ecs-ec2/README.md)

For test sample, see [ECS EC2 tests README](../../tests/ecs-ec2/README.md)

```hcl
module "otel_ecs_ec2_coralogix" {
  source                   = "github.com/coralogix/terraform-coralogix-aws/modules/ecs-ec2"
  ecs_cluster_name         = var.ecs_cluster_name
  image_version            = var.image_version
  memory                   = var.memory
  coralogix_region         = var.coralogix_region
  custom_domain            = var.custom_domain
  default_application_name = var.default_application_name
  default_subsystem_name   = var.default_subsystem_name
  api_key                  = var.api_key
  otel_config_file         = var.otel_config_file
  metrics                  = var.metrics
}
```

now execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Run `terraform destroy` when you don't need these resources.
