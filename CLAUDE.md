# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Terraform/OpenTofu monorepo following the multi-instance root modules pattern. The repository separates reusable infrastructure code (child modules) from deployment configurations (root modules).

## Project Purpose

This repository is being used to create a **Spacelift sponsored video** demonstrating AI-assisted infrastructure development with proper governance and policy enforcement.

**Demo Concept:**
1. Use AI to generate infrastructure code (Terraform for provisioning, Ansible for configuration)
2. Review the generated code like a platform team would
3. Run through Spacelift to enforce organizational policies
4. Intentionally trigger policy failures to demonstrate guardrails
5. Fix violations and deploy properly with full audit trail

**Key Message:** AI can accelerate infrastructure development, but without governance, audit trails, and policy checks, it becomes chaotic. Spacelift provides the necessary guardrails to safely leverage AI-generated code.

## Repository Structure

```
.
├── child-modules/       # Reusable Terraform modules (DRY components)
│   └── neo4j-web/      # Example: ECS-based web application module
└── root-modules/        # Deployment configurations (instantiable)
    ├── template-root-module/  # Template for new root modules
    └── neo4j-web/             # Example: Multi-instance deployment
        └── tfvars/            # Per-instance variable files
```

### Module Types

**Child Modules** (`child-modules/`):
- Reusable infrastructure components
- Version constraints: Use `>=` (minimum versions) for Terraform and providers
- No `providers.tf` file (configured by root module)
- Structure: `main.tf`, `variables.tf`, `versions.tf`, `outputs.tf`, and optionally `data.tf`
- May be organized by resource type (e.g., `ecs.tf`, `alb.tf`, `iam.tf`)

**Root Modules** (`root-modules/`):
- Deployment configurations that consume child modules
- Version constraints: Exact Terraform version + pessimistic (`~>`) provider versions
- Include `providers.tf` for provider configuration
- Structure: `main.tf`, `providers.tf`, `variables.tf`, `versions.tf`, `outputs.tf`, `data.tf`
- Multi-instance pattern: Use `tfvars/` directory for per-instance configurations

## Common Commands

### Linting and Formatting

```bash
# Run all linters and formatters (same as CI)
trunk check

# Auto-fix formatting issues
trunk fmt

# Run specific linter
trunk check --filter=tflint
trunk check --filter=tofu
```

### Terraform/OpenTofu Operations

```bash
# Initialize a root module
cd root-modules/<module-name>
tofu init  # or: terraform init

# Plan with specific tfvars file
tofu plan -var-file=tfvars/customer-A.tfvars

# Apply changes
tofu apply -var-file=tfvars/customer-A.tfvars

# Validate configuration
tofu validate
```

### Documentation

Documentation is auto-generated via terraform-docs on commit (trunk action):

```bash
# Manually regenerate docs (runs recursively on root-modules/)
terraform-docs .
```

Documentation is injected into README.md files between markers:
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
...
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
```

## Architecture Patterns

### Versioning Strategy

**Child Modules:**
- Use minimum version constraints to maximize compatibility
- Example: `required_version = ">= 1.3"` and `version = ">= 3.0"`
- Allows root modules to choose their own versions

**Root Modules:**
- Use exact Terraform version for consistency
- Use pessimistic operator (`~>`) for providers to allow patch updates
- Example: `required_version = "1.13.3"` and `version = "~> 3.7.2"`

### Module Sourcing

Root modules reference child modules using relative paths:

```hcl
module "example" {
  source = "../../child-modules/module-name"
  # ...
}
```

For external modules, use version pinning:

```hcl
# Terraform Registry
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "1.0.0"
}

# Git source
module "vpc" {
  source = "git::https://github.com/org/terraform-aws-vpc.git?ref=v1.0.0"
}
```

### Multi-Instance Root Modules

Each root module can be instantiated multiple times using `.tfvars` files:

```
root-modules/neo4j-web/
├── main.tf
├── variables.tf
├── providers.tf
├── versions.tf
└── tfvars/
    ├── customer-A.tfvars
    ├── customer-B.tfvars
    └── staging.tfvars
```

Deploy with: `tofu apply -var-file=tfvars/customer-A.tfvars`

## Linting and CI

The repository uses [Trunk Code Quality](https://docs.trunk.io/code-quality) for comprehensive code quality checks:

- **tofu/terraform**: Format and validate
- **terraform-docs**: Auto-generate module documentation
- **tflint**: Terraform-specific linting
- **trivy**: Security scanning
- **checkov**: Infrastructure security scanning
- **actionlint**: GitHub Actions workflow validation
- **markdownlint, prettier, yamllint**: General formatting

CI runs on all PRs via GitHub Actions (`.github/workflows/lint.yaml`).

## File Organization Guidelines

### Standard Files

1. **`main.tf`**: Core resources and module logic. May call child modules. Use `locals` blocks for DRY expressions.

2. **`variables.tf`**: Input variables with descriptions, types, defaults, and validation.

3. **`versions.tf`**: Terraform/OpenTofu and provider version constraints.

4. **`outputs.tf`**: Exported values for module consumers. Mark sensitive outputs with `sensitive = true`.

5. **`data.tf`** (optional): Data source declarations for external information lookup.

6. **`providers.tf`** (root modules only): Provider configurations with regions and authentication.

### Child Module Organization

For complex modules, split resources by service type:
- `ecs.tf`: ECS cluster, services, task definitions
- `alb.tf`: Application Load Balancer resources
- `iam.tf`: IAM roles and policies
- `ecr.tf`: ECR repositories

## Development Workflow

1. **Starting new work:**
   - For new root module: Copy `root-modules/template-root-module/`
   - For new child module: Follow structure in `child-modules/neo4j-web/`

2. **Before committing:**
   - Trunk runs auto-formatters on pre-commit hook
   - Documentation is auto-generated for root modules

3. **Pull requests:**
   - CI runs full lint suite via trunk-action
   - All checks must pass before merge

## Editor Configuration

The `.editorconfig` file enforces:
- UTF-8 encoding
- LF line endings
- 2-space indentation
- Trim trailing whitespace
- Final newline in all files
