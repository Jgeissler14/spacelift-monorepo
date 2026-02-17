resource "aws_ecs_cluster" "this" {
  count = var.create_cluster ? 1 : 0
  name  = var.project_name
}

resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project_name}/backend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${var.project_name}/frontend"
  retention_in_days = 30
}

locals {
  backend_env_list  = [for k, v in var.backend_env : { name = k, value = v }]
  frontend_env_list = [for k, v in var.frontend_env : { name = k, value = v }]
  backend_secret_list  = [for k, v in var.backend_secrets : { name = k, valueFrom = v } if v != null && trimspace(v) != ""]
  frontend_secret_list = [for k, v in var.frontend_secrets : { name = k, valueFrom = v } if v != null && trimspace(v) != ""]
  ecs_cluster_id    = var.create_cluster ? aws_ecs_cluster.this[0].id : var.cluster_arn
  ecs_cluster_name  = var.create_cluster ? aws_ecs_cluster.this[0].name : var.cluster_name
  backend_repo_url  = var.existing_backend_ecr_repository_url
  frontend_repo_url = var.existing_frontend_ecr_repository_url
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.backend_task_cpu
  memory                   = var.backend_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  ephemeral_storage {
    size_in_gib = var.backend_ephemeral_storage_gb
  }

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${local.backend_repo_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = local.backend_env_list
      secrets     = local.backend_secret_list
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.frontend_task_cpu
  memory                   = var.frontend_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  ephemeral_storage {
    size_in_gib = var.frontend_ephemeral_storage_gb
  }

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${local.frontend_repo_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = local.frontend_env_list
      secrets     = local.frontend_secret_list
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.frontend.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend"
  cluster         = local.ecs_cluster_id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"
  availability_zone_rebalancing = "ENABLED"
  force_new_deployment = true

  network_configuration {
    subnets         = length(var.backend_subnet_ids) > 0 ? var.backend_subnet_ids : var.private_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = var.backend_assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.http, aws_lb_listener.http_redirect, aws_lb_listener.https, aws_lb_listener.backend_http]
}

resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend"
  cluster         = local.ecs_cluster_id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"
  availability_zone_rebalancing = "ENABLED"
  force_new_deployment = true

  network_configuration {
    subnets         = length(var.frontend_subnet_ids) > 0 ? var.frontend_subnet_ids : var.public_subnet_ids
    security_groups = [aws_security_group.ecs_tasks.id]
    assign_public_ip = var.frontend_assign_public_ip
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.http, aws_lb_listener.http_redirect, aws_lb_listener.https, aws_lb_listener.backend_http]
}
