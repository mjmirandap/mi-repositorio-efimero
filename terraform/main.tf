# main.tf - Archivo completo con la creacion del cluster
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2" 
}

# 1. Cluster para ambiente efimero
resource "aws_ecs_cluster" "ephemeral_cluster" {
  name = "ephemeral-cluster-pr-${var.pr_number}"
}

# 2. TG para el ALB
resource "aws_lb_target_group" "ephemeral_tg" {
  name        = "ephemeral-tg-pr-${var.pr_number}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
}

# 3. Task definition
resource "aws_ecs_task_definition" "ephemeral_task" {
  family                   = "mi-app-pr-${var.pr_number}"
  
  container_definitions    = jsonencode([
    {
      "name"      = "mi-app-container",
      "image"     = "${var.ecr_url}:pr-${var.pr_number}", 
      "cpu"       = 256,
      "memory"    = 512,
      "essential" = true,
      "portMappings" = [
        {
          "containerPort" = 80,
          "hostPort"      = 80
        }
      ]
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
}

# 4. ECS service
resource "aws_ecs_service" "ephemeral_service" {
  name            = "mi-app-pr-${var.pr_number}"
  cluster         = aws_ecs_cluster.ephemeral_cluster.id
  task_definition = aws_ecs_task_definition.ephemeral_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = var.private_subnets
    security_groups = [aws_security_group.ephemeral_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ephemeral_tg.arn
    container_name   = "mi-app-container"
    container_port   = 80
  }
}

# 5. ALB
resource "aws_lb" "ephemeral_alb" {
  name               = "ephemeral-alb-pr-${var.pr_number}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ephemeral_sg.id]
  subnets            = var.public_subnets 
}

# 6. Listener del TG
resource "aws_lb_listener" "ephemeral_listener" {
  load_balancer_arn = aws_lb.ephemeral_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.ephemeral_tg.arn
    type             = "forward"
  }
}

# 7. URL publica generada
output "ephemeral_environment_url" {
  description = "URL publica del ambiente efimero"
  value       = aws_lb.ephemeral_alb.dns_name
}