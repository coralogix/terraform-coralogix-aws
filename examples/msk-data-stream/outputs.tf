output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "security_group_id" {
  value = aws_security_group.sg.id
}

output "cluster_arn" {
  value = aws_msk_cluster.coralogix-msk-cluster.arn
}
