output "required_tags_policy_id" {
  value       = spacelift_policy.required_tags.id
  description = "ID of the Required Tags policy"
}

output "security_policy_id" {
  value       = spacelift_policy.security.id
  description = "ID of the Security policy"
}

output "cost_control_policy_id" {
  value       = spacelift_policy.cost_control.id
  description = "ID of the Cost Control policy"
}

output "stacks" {
  value = {
    for stack_key, stack in spacelift_stack.infrastructure :
    stack_key => {
      id           = stack.id
      name         = stack.name
      project_root = stack.project_root
      url          = "https://app.spacelift.io/stack/${stack.id}"
    }
  }
  description = "All created infrastructure stacks"
}

output "stack_count" {
  value       = length(spacelift_stack.infrastructure)
  description = "Total number of stacks created"
}
