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

# Deny resources that are missing required tags
deny[msg] {
  resource := input.terraform.resource_changes[_]
  taggable_resources[resource.type]

  # Skip resources being deleted
  not resource.change.actions[_] == "delete"

  # Get all tags (check both tags and tags_all)
  tags := object.get(resource.change.after, "tags", {})
  tags_all := object.get(resource.change.after, "tags_all", {})
  all_tags := object.union(tags, tags_all)

  # Find missing required tags
  missing := [tag | tag := required_tags[_]; not all_tags[tag]]
  count(missing) > 0

  msg := sprintf(
    "Resource '%s' is missing required tags: %v. All resources must have: %v",
    [resource.address, missing, required_tags]
  )
}

# Sample for Spacelift UI
sample := true
