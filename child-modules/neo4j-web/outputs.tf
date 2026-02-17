output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "ALB DNS name."
}

output "backend_ecr_repository" {
  value       = local.backend_repo_url
  description = "Backend ECR repository URL."
}

output "frontend_ecr_repository" {
  value       = local.frontend_repo_url
  description = "Frontend ECR repository URL."
}

output "ecs_cluster_name" {
  value       = local.ecs_cluster_name
  description = "ECS cluster name."
}

output "backend_service_name" {
  value       = aws_ecs_service.backend.name
  description = "Backend ECS service name."
}

output "frontend_service_name" {
  value       = aws_ecs_service.frontend.name
  description = "Frontend ECS service name."
}
