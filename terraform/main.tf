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

resource "aws_ecs_cluster" "ephemeral_cluster" {
  name = "ephemeral-cluster-pr-${var.pr_number}"
}

resource "aws_ecs_task_definition" "ephemeral_task" {
  family                   = "mi-app-pr-${var.pr_number}"
  container_definitions    = jsonencode([
    {
      "name"      = "mi-app-container",
      "image"     = "286678351406.dkr.ecr.us-east-2.amazonaws.com/borrame-app-repo:verde",
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
}

resource "aws_ecs_service" "ephemeral_service" {
  name            = "mi-app-pr-${var.pr_number}"
  cluster         = aws_ecs_cluster.ephemeral_cluster.id
  task_definition = aws_ecs_task_definition.ephemeral_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = var.private_subnets
  }
}

output "ephemeral_cluster_name" {
  value = aws_ecs_cluster.ephemeral_cluster.name
}

output "ephemeral_service_url" {
  value = aws_ecs_service.ephemeral_service.id
}