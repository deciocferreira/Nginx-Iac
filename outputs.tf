output "load_balancer_dns_name" {
  value = aws_lb.ecs.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "nat_gateway_ips" {
  value = aws_nat_gateway.nat.*.allocation_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr-image.repository_url
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.ecs.name
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.ecs-logs.name
}