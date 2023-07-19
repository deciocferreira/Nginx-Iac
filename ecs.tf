# Cluster ECS
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.app_name}-${var.app_environment}-cluster"
  tags = {
    Name        = "${var.app_name}-ecs"
    Environment = var.app_environment
  }
}

# Serviço ECS
resource "aws_ecs_service" "ecs-service" {
  name                 = "${var.app_name}-${var.app_environment}-ecs-service"
  cluster              = aws_ecs_cluster.ecs-cluster.id
  task_definition      = "${aws_ecs_task_definition.aws-ecs-task.family}:${max(aws_ecs_task_definition.aws-ecs-task.revision, data.aws_ecs_task_definition.main.revision)}"
  launch_type          = "EC2"
  scheduling_strategy  = "REPLICA"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
      aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

  # Load Balancer do ECS
  resource "aws_lb" "applicationlb" {
    name               = "${var.app_name}-${var.app_environment}-alb"
    internal           = false
    load_balancer_type = "application"
    subnets            = aws_subnet.public.*.id
    security_groups    = [aws_security_group.load_balancer_security_group.id]

    tags = {
      Name        = "${var.app_name}-alb"
      Environment = var.app_environment
    }
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn
    container_name   = "${var.app_name}-${var.app_environment}-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.listener]
}

# Auto Scaling Group do ECS
resource "aws_autoscaling_group" "ecs" {
  name                 = "${var.app_name}-${var.app_environment}-AutoScalingGroup"
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = aws_subnet.private.*.id

  tag {
    key                 = "Name"
    value               = "ECSInstance"
    propagate_at_launch = true
  }
}
# Configuração de Lançamento do ECS
resource "aws_launch_configuration" "ecs" {
  name                 = "${var.app_name}-${var.app_environment}-ECSLaunchConfig"
  image_id             = "ami-xxxxxxxxxxxxxxxxx"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.ecs.id]
  iam_instance_profile = aws_iam_instance_profile.ecs.name
  user_data            = filebase64("${path.module}/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

# Notificação de escalabilidade do ECS
resource "aws_appautoscaling_target" "ecs-notification" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/MyECSCluster"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Logs do ECS
resource "aws_cloudwatch_log_group" "ecs-logs" {
  name = "${var.app_name}-${var.app_environment}-logs"

  retention_in_days = var.aws_cloudwatch_retention_in_days

  tags = {
    Application = var.app_name
    Environment = var.app_environment
  }
}