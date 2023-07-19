provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Recurso da VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "MeuProjeto-VPC"
  }
}

# Recurso de sub-redes públicas
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_blocks)
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a" # Substitua pela sua zona de disponibilidade

  tags = {
    Name = "PublicSubnet-${count.index}"
  }
}

# Recurso de sub-redes privadas
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = "us-east-1a" 

  tags = {
    Name = "PrivateSubnet-${count.index}"
  }
}

# Recurso do Registro do ECR
resource "aws_ecr_repository" "nginx" {
  name = "nginx"
}

# Recurso do Cluster ECS
resource "aws_ecs_cluster" "main" {
  name = "MyECSCluster"
}

# Recurso da Definição de Tarefa do ECS
resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  container_definitions    = jsonencode([{
    name  = "nginx-container"
    image = var.nginx_container_image
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"

  # Você também pode adicionar outros recursos aqui, como volumes, variáveis de ambiente, etc.
}

# Recurso do Load Balancer do ECS
resource "aws_lb" "ecs" {
  name               = "MyECSLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
}

# Recurso do Target Group do Load Balancer
resource "aws_lb_target_group" "ecs" {
  name     = "MyECSTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
  }
}

# Recurso de associação do Target Group com o Cluster ECS
resource "aws_lb_target_group_attachment" "ecs" {
  target_group_arn = aws_lb_target_group.ecs.arn
  target_id        = aws_ecs_cluster.main.id
}

# Recurso do Auto Scaling Group do ECS
resource "aws_autoscaling_group" "ecs" {
  name                 = "MyECSAutoScalingGroup"
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = aws_subnet.private.*.id

  tag {
    key                 = "Name"
    value               = "ECSInstance"
    propagate_at_launch = true
  }
}

# Recurso de Configuração de Lançamento do ECS
resource "aws_launch_configuration" "ecs" {
  name                 = "MyECSLaunchConfig"
  image_id             = "ami-xxxxxxxxxxxxxxxxx" # Substitua pela AMI de sua escolha
  instance_type        = "t2.micro" 
  security_groups      = [aws_security_group.ecs.id]
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  user_data            = filebase64("${path.module}/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Recurso do Security Group do ECS
resource "aws_security_group" "ecs" {
  name_prefix = "ECS-"
  vpc_id      = aws_vpc.main.id
}

# Recurso do Profile IAM do ECS
resource "aws_iam_instance_profile" "ecs" {
  name = "MyECSInstanceProfile"

  role = aws_iam_role.ecs.id
}

# Recurso da Regra do IAM para o ECS
resource "aws_iam_role" "ecs" {
  name = "MyECSRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Política do IAM para o ECS
resource "aws_iam_role_policy_attachment" "ecs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  role       = aws_iam_role.ecs.name
}

# Recurso de notificação de escalabilidade do ECS
resource "aws_appautoscaling_target" "ecs" {
  max_capacity       = 5
  min_capacity       = 1
  resource_id        = "service/MyECSCluster"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Recurso de política de escalabilidade do ECS
resource "aws_appautoscaling_policy" "ecs" {
  name               = "MyECSAutoScalingPolicy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    target_value       = 70.0
  }
}

# Recurso de log do ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/MyECSCluster"

  retention_in_days = 7
}