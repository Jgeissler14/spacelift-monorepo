package spacelift

# Helper to check if resource is being deleted
is_delete(resource) {
  resource.change.actions[_] == "delete"
}

# Warn about HTTP-only ALBs - HTTPS should be configured for production
warn[msg] {
  alb := input.terraform.resource_changes[_]
  alb.type == "aws_lb"
  not is_delete(alb)

  # Count HTTPS listeners
  https_count := count([1 |
    listener := input.terraform.resource_changes[_];
    listener.type == "aws_lb_listener";
    not is_delete(listener);
    listener.change.after.protocol == "HTTPS"
  ])

  https_count == 0

  msg := sprintf(
    "ALB '%s' should have an HTTPS listener configured. HTTP-only traffic is insecure and exposes data to interception.",
    [alb.address]
  )
}

# Warn about security groups with unrestricted access on non-standard ports
warn[msg] {
  sg := input.terraform.resource_changes[_]
  sg.type == "aws_security_group"
  not is_delete(sg)

  rule := sg.change.after.ingress[_]
  cidr := rule.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  # Warn about non-standard ports
  rule.from_port != 80
  rule.from_port != 443

  msg := sprintf(
    "Security group '%s' allows unrestricted access (0.0.0.0/0) on port %v. Consider restricting access to specific IP ranges.",
    [sg.address, rule.from_port]
  )
}

# Warn about ALBs without deletion protection
warn[msg] {
  alb := input.terraform.resource_changes[_]
  alb.type == "aws_lb"
  not is_delete(alb)

  deletion_protection := object.get(alb.change.after, "enable_deletion_protection", false)
  deletion_protection == false

  msg := sprintf(
    "ALB '%s' does not have deletion protection enabled. Enable it to prevent accidental deletion.",
    [alb.address]
  )
}

# Sample for Spacelift UI
sample := true
