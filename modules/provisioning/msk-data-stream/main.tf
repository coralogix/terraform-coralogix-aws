locals {
  coraloigx_role = var.custom_coralogix_arn == null ? lookup(var.coraloigx_roles_arn_mapping, var.aws_region) : var.custom_coralogix_arn
}

### data ###
data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_caller_identity" "current" {}

resource "random_string" "unique" {
  length  = 6
  numeric = true
  special = false
  upper   = false
}

### VPC ###
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block == null ? "193.169.0.0/20" : var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name               = "coralogix-msk-endpoint-vpc-${random_string.unique.result}"
    coralogix_resource = "coralogix msk vpc"
  }
}

### Public Subnets ###
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc_cidr_block == null ? "193.169.${count.index + 3}.0/24" : var.subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[count.index]
  tags = {
    Name               = "coralogix-msk-endpoint-public-subnet-${random_string.unique.result}"
    coralogix_resource = "coralogix msk subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    coralogix_resource = "coralogix msk internet gateway"
  }
}

resource "aws_route_table" "public" {
  count  = 3
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name               = "coralogix-msk-endpoint-public-route-table-${random_string.unique.result}"
    coralogix_resource = "coralogix msk route table"
  }
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_eip" "nat" {
  count  = 3
  domain = "vpc"
  tags = {
    coralogix_resource = "coralogix msk nat eip"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = 3
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    coralogix_resource = "coralogix msk nat gateway"
  }
}

### Security Group ###
resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 9198
    to_port     = 9198
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name               = "coralogix-msk-endpoint-security-group-${random_string.unique.result}"
    coralogix_resource = "coralogix msk security group"
  }
}

### MSK Cluster ###
resource "aws_msk_cluster" "coralogix-msk-cluster" {
  cluster_name           = var.cluster_name == "coralogix-msk-cluster" ? "coralogix-msk-cluster-${random_string.unique.result}" : var.cluster_name
  kafka_version          = "3.5.1"
  number_of_broker_nodes = 3
  client_authentication {
    sasl {
      iam = true
    }
  }
  broker_node_group_info {
    instance_type = var.instance_type
    client_subnets = [
      aws_subnet.public[0].id,
      aws_subnet.public[1].id,
      aws_subnet.public[2].id,
    ]
    storage_info {
      ebs_storage_info {
        volume_size = var.msk_storage_volume_size
      }
    }
    security_groups = [aws_security_group.sg.id]
  }
  tags = {
    coralogix_resource = "coralogix msk cluster"
  }
}

resource "aws_msk_cluster_policy" "coralogix-msk-cluster-policy" {
  cluster_arn = aws_msk_cluster.coralogix-msk-cluster.arn

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.coraloigx_role}"
        ]
      },
      "Action": [
        "kafka-cluster:Connect"
      ],
      "Resource": "${aws_msk_cluster.coralogix-msk-cluster.arn}"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${local.coraloigx_role}"
        ]
      },
      "Action": [
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:WriteData"
      ],
       "Resource": "arn:aws:kafka:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/${aws_msk_cluster.coralogix-msk-cluster.cluster_name}/*"
    }
  ]
  })
}

resource "null_resource" "enable-msk-public-access" {
  # Terraform don't support an option to update msk in the creation to have public access so we need to do it manually
  depends_on = [aws_msk_cluster.coralogix-msk-cluster]
  provisioner "local-exec" {
    command = <<-EOF
      current_version=$(aws --region ${var.aws_region} kafka describe-cluster --cluster-arn ${aws_msk_cluster.coralogix-msk-cluster.arn} --query 'ClusterInfo.CurrentVersion' --output text) && \
      aws --region ${var.aws_region} kafka update-connectivity \
        --cluster-arn ${aws_msk_cluster.coralogix-msk-cluster.arn} \
        --current-version $${current_version} \
        --connectivity-info '{"PublicAccess": {"Type": "SERVICE_PROVIDED_EIPS"}}' && \
      
      echo "Waiting for MSK cluster to finish updating..." && \
      while true; do \
        status=$(aws --region ${var.aws_region} kafka describe-cluster --cluster-arn ${aws_msk_cluster.coralogix-msk-cluster.arn} --query 'ClusterInfo.State' --output text); \
        if [ "$${status}" == "ACTIVE" ]; then \
          echo "MSK cluster is active"; \
          break; \
        elif [ "$${status}" == "FAILED" ]; then \
          echo "MSK cluster update failed"; \
          exit 1; \
        else \
          echo "MSK cluster is still updating..."; \
        fi; \
        sleep 30; \
      done
    EOF
  }
}


