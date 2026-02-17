package spacelift

# Deny HTTP-only ALBs - HTTPS should be configured
deny[msg] {
  alb := input.terraform.resource_changes[_]
  alb.type == "aws_lb"
  alb.change.actions[_] != "delete"

  # Check if any HTTPS listener exists for this ALB
  alb_name := alb.change.after.name

  # Count HTTPS listeners
  https_listeners := [listener |
    listener := input.terraform.resource_changes[_];
    listener.type == "aws_lb_listener";
    listener.change.actions[_] != "delete";
    listener.change.after.protocol == "HTTPS"
  ]

  count(https_listeners) == 0

  msg := sprintf(
    "ALB '%s' must have an HTTPS listener configured. HTTP-only traffic is insecure and exposes data to interception.",
    [alb.address]
  )
}

# Warn about security groups with unrestricted access on non-standard ports
warn[msg] {
  sg := input.terraform.resource_changes[_]
  sg.type == "aws_security_group"
  sg.change.actions[_] != "delete"

  rule := sg.change.after.ingress[_]
  cidr := rule.cidr_blocks[_]
  cidr == "0.0.0.0/0"

  # Allow 80 and 443 for ALBs, but warn about other ports
  not rule.from_port == 80
  not rule.from_port == 443

  msg := sprintf(
    "Security group '%s' allows unrestricted access (0.0.0.0/0) on port %v. Consider restricting access to specific IP ranges.",
    [sg.address, rule.from_port]
  )
}

# Warn about ALBs without deletion protection
warn[msg] {
  alb := input.terraform.resource_changes[_]
  alb.type == "aws_lb"
  alb.change.actions[_] != "delete"

  # Check if deletion protection is explicitly disabled or not set
  deletion_protection := object.get(alb.change.after, "enable_deletion_protection", false)
  deletion_protection == false

  msg := sprintf(
    "ALB '%s' does not have deletion protection enabled. Enable it to prevent accidental deletion.",
    [alb.address]
  )
}

# Sample for Spacelift UI
sample := true
