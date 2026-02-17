# This root module manages Spacelift policies as code
# Deploy this as a separate Spacelift stack to manage your policies

# Policy 1: Required Tags (DENY)
resource "spacelift_policy" "required_tags" {
  name = "Required Tags"
  body = file("${path.module}/policies/required-tags.rego")
  type = "PLAN"

  labels = ["security", "compliance", "governance"]
}

# Policy 2: Security Best Practices (DENY + WARN)
resource "spacelift_policy" "security" {
  name = "Security Best Practices"
  body = file("${path.module}/policies/security-policy.rego")
  type = "PLAN"

  labels = ["security", "best-practices"]
}

# Policy 3: Cost Control (WARN)
resource "spacelift_policy" "cost_control" {
  name = "Cost Control"
  body = file("${path.module}/policies/cost-control.rego")
  type = "PLAN"

  labels = ["cost", "optimization"]
}

# Create infrastructure stacks
resource "spacelift_stack" "neo4j_web_good" {
  name         = "neo4j-web-customer-good"
  repository   = "spacelift-monorepo"
  branch       = "main"
  project_root = "root-modules/neo4j-web"

  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "1.11.5"
  administrative          = false
  autodeploy              = false

  labels = ["neo4j", "production", "customer", "opentofu"]
}

resource "spacelift_stack" "neo4j_web_bad" {
  name         = "neo4j-web-customer-bad"
  repository   = "spacelift-monorepo"
  branch       = "main"
  project_root = "root-modules/neo4j-web"

  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "1.11.5"
  administrative          = false
  autodeploy              = false

  labels = ["neo4j", "demo", "customer", "opentofu"]
}

# Environment variables for customer-good stack
resource "spacelift_environment_variable" "good_tfvars_plan" {
  stack_id = spacelift_stack.neo4j_web_good.id
  name     = "TF_CLI_ARGS_plan"
  value    = "-var-file=tfvars/customer-good.tfvars"
}

resource "spacelift_environment_variable" "good_tfvars_apply" {
  stack_id = spacelift_stack.neo4j_web_good.id
  name     = "TF_CLI_ARGS_apply"
  value    = "-var-file=tfvars/customer-good.tfvars"
}

# Environment variables for customer-bad stack
resource "spacelift_environment_variable" "bad_tfvars_plan" {
  stack_id = spacelift_stack.neo4j_web_bad.id
  name     = "TF_CLI_ARGS_plan"
  value    = "-var-file=tfvars/customer-bad.tfvars"
}

resource "spacelift_environment_variable" "bad_tfvars_apply" {
  stack_id = spacelift_stack.neo4j_web_bad.id
  name     = "TF_CLI_ARGS_apply"
  value    = "-var-file=tfvars/customer-bad.tfvars"
}

# Attach policies to both stacks
resource "spacelift_policy_attachment" "good_required_tags" {
  policy_id = spacelift_policy.required_tags.id
  stack_id  = spacelift_stack.neo4j_web_good.id
}

resource "spacelift_policy_attachment" "good_security" {
  policy_id = spacelift_policy.security.id
  stack_id  = spacelift_stack.neo4j_web_good.id
}

resource "spacelift_policy_attachment" "good_cost" {
  policy_id = spacelift_policy.cost_control.id
  stack_id  = spacelift_stack.neo4j_web_good.id
}

resource "spacelift_policy_attachment" "bad_required_tags" {
  policy_id = spacelift_policy.required_tags.id
  stack_id  = spacelift_stack.neo4j_web_bad.id
}

resource "spacelift_policy_attachment" "bad_security" {
  policy_id = spacelift_policy.security.id
  stack_id  = spacelift_stack.neo4j_web_bad.id
}

resource "spacelift_policy_attachment" "bad_cost" {
  policy_id = spacelift_policy.cost_control.id
  stack_id  = spacelift_stack.neo4j_web_bad.id
}

# Optional: Attach AWS integration to stacks (if provided)
resource "spacelift_aws_integration_attachment" "good" {
  count = var.aws_integration_id != "" ? 1 : 0

  integration_id = var.aws_integration_id
  stack_id       = spacelift_stack.neo4j_web_good.id
  read           = true
  write          = true
}

resource "spacelift_aws_integration_attachment" "bad" {
  count = var.aws_integration_id != "" ? 1 : 0

  integration_id = var.aws_integration_id
  stack_id       = spacelift_stack.neo4j_web_bad.id
  read           = true
  write          = true
}
