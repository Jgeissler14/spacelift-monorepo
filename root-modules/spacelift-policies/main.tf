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

# Optional: Automatically attach policies to stacks with specific labels
# Uncomment and customize as needed
#
# resource "spacelift_policy_attachment" "neo4j_stacks" {
#   for_each = toset([
#     "neo4j-web-customer-good",
#     "neo4j-web-customer-bad",
#   ])
#
#   policy_id = spacelift_policy.required_tags.id
#   stack_id  = each.value
# }
