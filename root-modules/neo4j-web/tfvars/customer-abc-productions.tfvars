# ABC Productions - Development Environment

project_name = "abc-productions-neo4j-dev"

# Development configuration - single instance
frontend_desired_count = 1
backend_desired_count  = 1

# Environment variables for frontend (nginx template)
frontend_env = {
  AUT0_DOMAIN              = "-"
  VITE_BACKEND_API_URL     = "http://abc-productions-neo4j-dev-320965403.us-east-1.elb.amazonaws.com:8000"
  VITE_FRONTEND_HOSTNAME   = "-"
  VITE_SEGMENT_API_URL     = "-"
}

# Environment variables for backend (Neo4j connection)
backend_env = {
  NEO4J_URI                     = "neo4j+s://0d374cb6.databases.neo4j.io"
  NEO4J_USERNAME                = "neo4j"
  NEO4J_DATABASE                = "neo4j"
  KNN_MIN_SCORE                 = "0.94"
  IS_EMBEDDING                  = "true"
  UPDATE_GRAPH_CHUNKS_PROCESSED = "20"
  ENTITY_EMBEDDING              = "false"
  GCS_FILE_CACHE                = "false"
}

# Secrets from AWS Secrets Manager (using shared credentials)
backend_secrets = {
  NEO4J_PASSWORD                     = "arn:aws:secretsmanager:us-east-1:203918842750:secret:colossus-knowledge-manager/neo4j-password-J6tUHp"
  LLM_MODEL_CONFIG_OPENAI_GPT_5_MINI = "arn:aws:secretsmanager:us-east-1:203918842750:secret:colossus-knowledge-manager/openai-model-config-gwiymS"
  LLM_MODEL_CONFIG_OPENAI_GPT_5_2    = "arn:aws:secretsmanager:us-east-1:203918842750:secret:colossus-knowledge-manager/openai-model-config-gpt52-rl1g2T"
  OPENAI_API_KEY                     = "arn:aws:secretsmanager:us-east-1:203918842750:secret:colossus-knowledge-manager/openai-api-key-QPoFDq"
}

# Required tags for governance and cost tracking
default_tags = {
  Environment     = "dev"
  Owner           = "jrgeissler14@gmail.com"
  CostCenter      = "engineering"
  Project         = "neo4j-abc-productions"
  ManagedBy       = "terraform"
  DataSensitivity = "high"
  BackupPolicy    = "daily"
  Compliance      = "none"
}
