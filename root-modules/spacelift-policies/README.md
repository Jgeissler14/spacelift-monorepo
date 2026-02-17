# Spacelift Administrative Stack

**Fully dynamic stack-of-stacks management.** This stack automatically creates infrastructure stacks based on your configuration.

## How It Works

Define your root modules and tfvars files in `variables.tf`:

```hcl
variable "root_modules" {
  default = {
    neo4j-web = {
      project_root = "root-modules/neo4j-web"
      tfvars_files = ["customer-good.tfvars", "customer-bad.tfvars"]
    }
    # Add more modules here!
  }
}
```

The stack automatically creates:
- ✅ One Spacelift stack per tfvars file
- ✅ All 3 policies attached to each stack
- ✅ AWS integration attached to each stack
- ✅ Environment variables configured

## Adding New Stacks

### Option 1: Add a new tfvars file to an existing module

Just add the file to the list:

```hcl
neo4j-web = {
  project_root = "root-modules/neo4j-web"
  tfvars_files = [
    "customer-good.tfvars",
    "customer-bad.tfvars",
    "customer-staging.tfvars"  # ← New!
  ]
}
```

### Option 2: Add a completely new root module

```hcl
root_modules = {
  neo4j-web = { ... }

  my-new-app = {  # ← New module!
    project_root = "root-modules/my-new-app"
    tfvars_files = ["dev.tfvars", "prod.tfvars"]
  }
}
```

Then `terraform apply` and it creates the new stacks!

## Setup

1. **Create this administrative stack** in Spacelift UI
2. **Set environment variables:**
   ```bash
   SPACELIFT_API_KEY_ENDPOINT=https://yourorg.app.spacelift.io
   SPACELIFT_API_KEY_ID=01HXXX...
   SPACELIFT_API_KEY_SECRET=xxx
   TF_VAR_aws_integration_id=01HXXX...
   ```
3. **Deploy:** Trigger run → Creates all stacks!

## Stack Naming

Stacks are named: `{module-name}-{tfvars-name}`

Examples:
- `neo4j-web-customer-good` (from `customer-good.tfvars`)
- `neo4j-web-customer-bad` (from `customer-bad.tfvars`)

## Benefits

- 🚀 **Zero manual clicking** - everything is code
- 📦 **Scalable** - add 10 new stacks by editing one variable
- 🔄 **Consistent** - all stacks get the same policies and settings
- 🧹 **Clean** - remove a tfvars file, stack gets destroyed
