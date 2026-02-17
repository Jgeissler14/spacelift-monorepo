variable "github_namespace" {
  type        = string
  description = "GitHub organization or username (e.g., 'yourorg' or 'yourusername')"
}

variable "aws_integration_id" {
  type        = string
  description = "Spacelift AWS integration ID to attach to infrastructure stacks"
  default     = ""
}
