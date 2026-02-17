terraform {
  required_version = "1.13.3"

  required_providers {
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.17.0"
    }
  }
}
