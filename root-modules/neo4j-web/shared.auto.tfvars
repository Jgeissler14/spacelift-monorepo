# Shared configuration across all customer deployments
# This file is automatically loaded by Terraform

region = "us-east-1"

# ECR repositories (shared across all environments)
existing_backend_ecr_repository_url  = "203918842750.dkr.ecr.us-east-1.amazonaws.com/colossus-knowledge-manager-backend"
existing_frontend_ecr_repository_url = "203918842750.dkr.ecr.us-east-1.amazonaws.com/colossus-knowledge-manager-frontend"

# VPC Configuration - Neo4j VPC
vpc_id = "vpc-0ea18145b731d1c29" # neo4j-vpc-internal-dev

# Subnets - ALB in public, ECS tasks in private for security
public_subnet_ids = [
  "subnet-0b096dd0c323cd9ca", # neo4j-public-subnet-internal-dev-us-east-1a
  "subnet-07ef5b2e3992c8280"  # neo4j-public-subnet-internal-dev-us-east-1b
]
private_subnet_ids = [
  "subnet-0e965b7f5e047f615", # neo4j-private-subnet-internal-dev-us-east-1a
  "subnet-0e0059a99f6e406ea"  # neo4j-private-subnet-internal-dev-us-east-1b
]

# Default ECS configuration
frontend_task_cpu    = 512
frontend_task_memory = 1024
backend_task_cpu     = 2048
backend_task_memory  = 8192

backend_ephemeral_storage_gb  = 50
frontend_ephemeral_storage_gb = 21
