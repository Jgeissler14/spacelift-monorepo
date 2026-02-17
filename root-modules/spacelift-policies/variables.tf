variable "github_namespace" {
  type        = string
  description = "GitHub organization or username"
  default     = "jgeissler14"
}

variable "aws_integration_id" {
  type        = string
  description = "Spacelift AWS integration ID to attach to infrastructure stacks"
}

variable "root_modules" {
  type = map(object({
    project_root = string
    tfvars_files = list(string) # List of tfvars files (without path, e.g., ["customer-good.tfvars", "customer-bad.tfvars"])
  }))
  description = "Map of root modules to create stacks for"
  default = {
    neo4j-web = {
      project_root = "root-modules/neo4j-web"
      tfvars_files = ["customer-good.tfvars", "customer-bad.tfvars"]
    }
  }
}
