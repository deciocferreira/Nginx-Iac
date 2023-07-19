output "load_balancer_dns_name" {
  value = aws_lb.ecs.dns_name
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.id
}