variable "github_namespace" {
  type        = string
  description = "GitHub organization or username"
  default     = "jgeissler14"
}

variable "aws_integration_id" {
  type        = string
  description = "Spacelift AWS integration ID to attach to infrastructure stacks"
}
