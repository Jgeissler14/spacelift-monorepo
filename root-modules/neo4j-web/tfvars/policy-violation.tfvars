# Bad customer deployment - intentional policy violations for demo

project_name = "demo-neo4j-dev"

# POLICY VIOLATION: No HTTPS certificate - using insecure HTTP only
# acm_certificate_arn = ""
# frontend_domain     = ""
# backend_domain      = ""
# route53_zone_id     = ""

# POLICY VIOLATION: Single instance - no high availability
frontend_desired_count = 1
backend_desired_count  = 1

# Lower resource allocation (for cost demo)
frontend_task_cpu    = 256
frontend_task_memory = 512
backend_task_cpu     = 1024
backend_task_memory  = 2048

backend_ephemeral_storage_gb = 30

# Environment variables for backend (Neo4j connection)
backend_env = {
  NEO4J_URI                     = "neo4j+s://demo.databases.neo4j.io"
  NEO4J_USERNAME                = "neo4j"
  NEO4J_DATABASE                = "neo4j"
  KNN_MIN_SCORE                 = "0.85"
  IS_EMBEDDING                  = "true"
  UPDATE_GRAPH_CHUNKS_PROCESSED = "10"
  ENTITY_EMBEDDING              = "false"
  GCS_FILE_CACHE                = "false"
}

# Minimal secrets for demo
backend_secrets = {
  NEO4J_PASSWORD = "arn:aws:secretsmanager:us-east-1:203918842750:secret:demo-neo4j/password-AbCdEf"
  OPENAI_API_KEY = "arn:aws:secretsmanager:us-east-1:203918842750:secret:demo-neo4j/openai-key-GhIjKl"
}

# POLICY VIOLATION: Missing required tags
# Required: Environment, Owner, CostCenter, DataSensitivity, BackupPolicy, Compliance
default_tags = {
  Project   = "demo"
  ManagedBy = "terraform"
}
