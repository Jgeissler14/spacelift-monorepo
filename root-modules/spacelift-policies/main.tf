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

# Create locals for dynamic stack generation
locals {
  # Flatten root modules and tfvars into individual stacks
  stacks = merge([
    for module_name, module_config in var.root_modules : {
      for tfvars_file in module_config.tfvars_files :
      "${module_name}-${replace(tfvars_file, ".tfvars", "")}" => {
        module_name  = module_name
        project_root = module_config.project_root
        tfvars_file  = tfvars_file
      }
    }
  ]...)

  # Create policy list for dynamic attachment
  policies = {
    required_tags = spacelift_policy.required_tags.id
    security      = spacelift_policy.security.id
    cost_control  = spacelift_policy.cost_control.id
  }

  # Create policy-stack attachment combinations
  policy_attachments = merge([
    for stack_key, stack_config in local.stacks : {
      for policy_name, policy_id in local.policies :
      "${stack_key}-${policy_name}" => {
        policy_id = policy_id
        stack_id  = spacelift_stack.infrastructure[stack_key].id
      }
    }
  ]...)
}

# Dynamically create stacks based on root modules and tfvars
resource "spacelift_stack" "infrastructure" {
  for_each = local.stacks

  name         = each.key
  repository   = "spacelift-monorepo"
  branch       = "main"
  project_root = each.value.project_root

  terraform_workflow_tool = "OPEN_TOFU"
  terraform_version       = "1.11.5"
  administrative          = false
  autodeploy              = false

  labels = [
    each.value.module_name,
    replace(each.value.tfvars_file, ".tfvars", ""),
    "opentofu",
    "managed-by-terraform"
  ]
}

# Environment variables for each stack (tfvars file)
resource "spacelift_environment_variable" "tfvars_plan" {
  for_each = local.stacks

  stack_id = spacelift_stack.infrastructure[each.key].id
  name     = "TF_CLI_ARGS_plan"
  value    = "-var-file=tfvars/${each.value.tfvars_file}"
}

resource "spacelift_environment_variable" "tfvars_apply" {
  for_each = local.stacks

  stack_id = spacelift_stack.infrastructure[each.key].id
  name     = "TF_CLI_ARGS_apply"
  value    = "-var-file=tfvars/${each.value.tfvars_file}"
}

# Attach all policies to all stacks
resource "spacelift_policy_attachment" "stacks" {
  for_each = local.policy_attachments

  policy_id = each.value.policy_id
  stack_id  = each.value.stack_id
}

# Attach AWS integration to all stacks
resource "spacelift_aws_integration_attachment" "stacks" {
  for_each = local.stacks

  integration_id = var.aws_integration_id
  stack_id       = spacelift_stack.infrastructure[each.key].id
  read           = true
  write          = true
}
