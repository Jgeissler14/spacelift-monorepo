# Shared configuration across all customer deployments
# This file is automatically loaded by Terraform

region = "us-east-1"

# ECR repositories (shared across all environments)
existing_backend_ecr_repository_url  = "203918842750.dkr.ecr.us-east-1.amazonaws.com/colossus-knowledge-manager-backend"
existing_frontend_ecr_repository_url = "203918842750.dkr.ecr.us-east-1.amazonaws.com/colossus-knowledge-manager-frontend"

# VPC Configuration (replace with your actual VPC)
vpc_id = "vpc-0123456789abcdef0" # TODO: Replace with actual VPC ID

# Subnets (replace with your actual subnet IDs)
# For Fargate, tasks can run in public subnets with public IPs
public_subnet_ids  = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
private_subnet_ids = ["subnet-0fedcba9876543210", "subnet-0fedcba9876543211"]

# Default ECS configuration
frontend_task_cpu    = 512
frontend_task_memory = 1024
backend_task_cpu     = 2048
backend_task_memory  = 8192

backend_ephemeral_storage_gb  = 50
frontend_ephemeral_storage_gb = 21
