package spacelift

# List of tags that MUST be present on all taggable resources
required_tags := [
  "Environment",
  "Owner",
  "CostCenter",
  "DataSensitivity",
  "BackupPolicy",
  "Compliance",
]

# Resource types that should have tags
taggable_resources := {
  "aws_ecs_cluster",
  "aws_ecs_service",
  "aws_lb",
  "aws_lb_target_group",
  "aws_security_group",
  "aws_cloudwatch_log_group",
}

# Helper to check if resource is being deleted
is_delete(resource) {
  resource.change.actions[_] == "delete"
}

# Deny resources that are missing required tags
deny[msg] {
  resource := input.terraform.resource_changes[_]
  taggable_resources[resource.type]
  not is_delete(resource)

  # Get all tags (check both tags and tags_all)
  tags := object.get(resource.change.after, "tags", {})
  tags_all := object.get(resource.change.after, "tags_all", {})
  all_tags := object.union(tags, tags_all)

  # Check for missing tags
  tag := required_tags[_]
  not all_tags[tag]

  missing := [t | t := required_tags[_]; not all_tags[t]]

  msg := sprintf(
    "Resource '%s' is missing required tags: %v. All resources must have: %v",
    [resource.address, missing, required_tags]
  )
}

# Sample for Spacelift UI
sample := true
