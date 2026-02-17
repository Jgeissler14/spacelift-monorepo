output "alb_dns_name" {
  value       = module.neo4j_web.alb_dns_name
  description = "ALB DNS name for accessing the application"
}

output "backend_ecr_repository" {
  value       = module.neo4j_web.backend_ecr_repository
  description = "Backend ECR repository URL"
}

output "frontend_ecr_repository" {
  value       = module.neo4j_web.frontend_ecr_repository
  description = "Frontend ECR repository URL"
}

output "ecs_cluster_name" {
  value       = module.neo4j_web.ecs_cluster_name
  description = "ECS cluster name"
}

output "backend_service_name" {
  value       = module.neo4j_web.backend_service_name
  description = "Backend ECS service name"
}

output "frontend_service_name" {
  value       = module.neo4j_web.frontend_service_name
  description = "Frontend ECS service name"
}
