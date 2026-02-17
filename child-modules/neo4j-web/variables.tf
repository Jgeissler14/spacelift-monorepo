variable "project_name" {
  type        = string
  default     = "colossus-knowledge-manager"
  description = "Name prefix for resources."
}

variable "create_cluster" {
  type        = bool
  default     = true
  description = "Create a new ECS cluster for the services."
}

variable "cluster_arn" {
  type        = string
  default     = ""
  description = "Existing ECS cluster ARN to deploy into when create_cluster is false."
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "Existing ECS cluster name to expose when create_cluster is false."
}

variable "region" {
  type        = string
  description = "AWS region."
}

variable "vpc_id" {
  type        = string
  description = "Existing VPC ID for the services."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for the ALB."
}

variable "alb_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Override subnets for the ALB. Defaults to public_subnet_ids."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnets for ECS tasks."
}

variable "frontend_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Override subnets for frontend service. Defaults to public_subnet_ids."
}

variable "backend_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Override subnets for backend service. Defaults to private_subnet_ids."
}

variable "frontend_assign_public_ip" {
  type        = bool
  default     = true
  description = "Assign public IPs to frontend tasks when using public subnets."
}

variable "backend_assign_public_ip" {
  type        = bool
  default     = false
  description = "Assign public IPs to backend tasks (set true if no NAT)."
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN for HTTPS. Leave empty to use HTTP only."
}

variable "frontend_domain" {
  type        = string
  default     = ""
  description = "Frontend DNS name (e.g., graph.example.com)."
}

variable "backend_domain" {
  type        = string
  default     = ""
  description = "Backend DNS name (e.g., graph-api.example.com)."
}

variable "route53_zone_id" {
  type        = string
  default     = ""
  description = "Route53 hosted zone ID for optional DNS records."
}

variable "frontend_desired_count" {
  type        = number
  default     = 1
  description = "Number of frontend tasks."
}

variable "backend_desired_count" {
  type        = number
  default     = 1
  description = "Number of backend tasks."
}

variable "frontend_task_cpu" {
  type        = number
  default     = 512
  description = "Frontend task CPU units."
}

variable "frontend_task_memory" {
  type        = number
  default     = 1024
  description = "Frontend task memory (MiB)."
}

variable "backend_task_cpu" {
  type        = number
  default     = 2048
  description = "Backend task CPU units."
}

variable "backend_task_memory" {
  type        = number
  default     = 8192
  description = "Backend task memory (MiB)."
}

variable "backend_ephemeral_storage_gb" {
  type        = number
  default     = 50
  description = "Ephemeral storage for backend task (GiB)."
}

variable "frontend_ephemeral_storage_gb" {
  type        = number
  default     = 21
  description = "Ephemeral storage for frontend task (GiB)."
}

variable "backend_env" {
  type        = map(string)
  default     = {}
  description = "Plain environment variables for backend container."
}

variable "frontend_env" {
  type        = map(string)
  default     = {}
  description = "Plain environment variables for frontend container (nginx template vars)."
}

variable "backend_secrets" {
  type        = map(string)
  default     = {}
  description = "Backend secrets map of ENV_VAR -> Secrets Manager or SSM ARN."
}

variable "frontend_secrets" {
  type        = map(string)
  default     = {}
  description = "Frontend secrets map of ENV_VAR -> Secrets Manager or SSM ARN."
}

variable "existing_backend_ecr_repository_url" {
  type        = string
  description = "Existing backend ECR repository URL (required)."
}

variable "existing_frontend_ecr_repository_url" {
  type        = string
  description = "Existing frontend ECR repository URL (required)."
}
