module "neo4j_web" {
  source = "../../child-modules/neo4j-web"

  project_name = var.project_name
  region       = var.region

  vpc_id              = var.vpc_id
  public_subnet_ids   = var.public_subnet_ids
  alb_subnet_ids      = var.alb_subnet_ids
  private_subnet_ids  = var.private_subnet_ids
  frontend_subnet_ids = var.frontend_subnet_ids
  backend_subnet_ids  = var.backend_subnet_ids

  frontend_assign_public_ip = var.frontend_assign_public_ip
  backend_assign_public_ip  = var.backend_assign_public_ip

  acm_certificate_arn = var.acm_certificate_arn
  frontend_domain     = var.frontend_domain
  backend_domain      = var.backend_domain
  route53_zone_id     = var.route53_zone_id

  frontend_desired_count = var.frontend_desired_count
  backend_desired_count  = var.backend_desired_count
  frontend_task_cpu      = var.frontend_task_cpu
  frontend_task_memory   = var.frontend_task_memory
  backend_task_cpu       = var.backend_task_cpu
  backend_task_memory    = var.backend_task_memory

  backend_ephemeral_storage_gb  = var.backend_ephemeral_storage_gb
  frontend_ephemeral_storage_gb = var.frontend_ephemeral_storage_gb

  backend_env  = var.backend_env
  frontend_env = var.frontend_env

  backend_secrets  = var.backend_secrets
  frontend_secrets = var.frontend_secrets

  existing_backend_ecr_repository_url  = var.existing_backend_ecr_repository_url
  existing_frontend_ecr_repository_url = var.existing_frontend_ecr_repository_url
}
