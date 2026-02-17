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

output "policy_summary" {
  value = {
    required_tags = {
      id   = spacelift_policy.required_tags.id
      name = spacelift_policy.required_tags.name
      type = spacelift_policy.required_tags.type
    }
    security = {
      id   = spacelift_policy.security.id
      name = spacelift_policy.security.name
      type = spacelift_policy.security.type
    }
    cost_control = {
      id   = spacelift_policy.cost_control.id
      name = spacelift_policy.cost_control.name
      type = spacelift_policy.cost_control.type
    }
  }
  description = "Summary of all created policies"
}

output "stack_ids" {
  value = {
    customer_good = spacelift_stack.neo4j_web_good.id
    customer_bad  = spacelift_stack.neo4j_web_bad.id
  }
  description = "IDs of created stacks"
}

output "stack_urls" {
  value = {
    customer_good = "https://app.spacelift.io/stack/${spacelift_stack.neo4j_web_good.id}"
    customer_bad  = "https://app.spacelift.io/stack/${spacelift_stack.neo4j_web_bad.id}"
  }
  description = "URLs to view stacks in Spacelift UI"
}
