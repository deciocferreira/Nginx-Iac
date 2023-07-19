# VPC
resource "aws_vpc" "nginx-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}

# Sub-rede públicas
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_blocks)
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.nginx-vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

# Sub-redes privadas
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.nginx-vpc.id
  availability_zone = "us-east-1a"

  tags = {
    Name        = "${var.app_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
}

# NAT Gateway 
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.aws_vpc.nginx-vpc.id 

  tags = {
    Name = "${var.app_name}-NATGateway"
  }
}

# Elastic IP (EIP)
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.app_name}-NATEIP"
  }
}

# Rota para o Gateway NAT
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Target Group do ECS Load Balancer
resource "aws_lb_target_group" "ecs" {
  name     = "${var.app_name}-TargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/v1/status"
  }
}

# Target Group do Cluster ECS
resource "aws_lb_target_group_attachment" "ecs" {
  target_group_arn = aws_lb_target_group.ecs.arn
  target_id        = aws_ecs_cluster.main.id
}