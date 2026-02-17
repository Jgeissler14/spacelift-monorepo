# Spacelift Administrative Stack

**Fully automatic stack discovery.** This stack automatically discovers and creates Spacelift stacks based on your repository structure.

## How It Works

The stack automatically scans your repository:

```
root-modules/
├── neo4j-web/
│   └── tfvars/
│       ├── customer-good.tfvars  → Creates "neo4j-web-customer-good" stack
│       └── customer-bad.tfvars   → Creates "neo4j-web-customer-bad" stack
└── my-app/
    └── tfvars/
        ├── dev.tfvars   → Creates "my-app-dev" stack
        └── prod.tfvars  → Creates "my-app-prod" stack
```

**Zero configuration needed!** Just add:
1. A new module in `root-modules/`
2. Add `.tfvars` files in `{module}/tfvars/`
3. Push to git
4. Spacelift auto-applies → New stacks created! 🎉

## What Gets Created

For each `.tfvars` file found:
- ✅ One Spacelift stack
- ✅ All 3 policies attached
- ✅ AWS integration attached
- ✅ Environment variables configured

## Adding New Stacks

### Just add a tfvars file!

```bash
# Add a new customer
echo 'project_name = "acme-staging"' > root-modules/neo4j-web/tfvars/customer-staging.tfvars

# Commit and push
git add root-modules/neo4j-web/tfvars/customer-staging.tfvars
git commit -m 'Add staging customer'
git push

# Spacelift automatically detects and creates the stack!
```

### Or create a new module:

```bash
# Create new module
mkdir -p root-modules/my-app/tfvars
echo 'environment = "prod"' > root-modules/my-app/tfvars/prod.tfvars

# Commit and push - stack gets created automatically!
```

## Setup

1. **Create this administrative stack** in Spacelift UI
   - Name: `spacelift-admin`
   - Project root: `root-modules/spacelift-policies`
   - Administrative: ✅ YES

2. **Set environment variables:**
   ```bash
   SPACELIFT_API_KEY_ENDPOINT=https://yourorg.app.spacelift.io
   SPACELIFT_API_KEY_ID=01HXXX...
   SPACELIFT_API_KEY_SECRET=xxx
   TF_VAR_aws_integration_id=01HXXX...
   ```

3. **Deploy:** Trigger run → Discovers and creates all stacks!

## Stack Naming

Stacks are automatically named: `{module-name}-{tfvars-basename}`

Examples:
- `neo4j-web-customer-good` (from `customer-good.tfvars`)
- `neo4j-web-customer-bad` (from `customer-bad.tfvars`)
- `my-app-prod` (from `prod.tfvars`)

## Benefits

- 🚀 **Zero configuration** - just add files
- 📁 **Convention over configuration** - follows repo structure
- 🔄 **Self-documenting** - repo structure = infrastructure
- 🧹 **Auto-cleanup** - delete tfvars = stack destroyed
- 📦 **Infinite scale** - add 1000 stacks without touching this code

## How Discovery Works

The `scripts/discover-stacks.sh` script:
1. Scans `root-modules/` for directories
2. Looks for `tfvars/*.tfvars` in each module
3. Returns JSON map of all stacks to create
4. Terraform uses this to dynamically create resources

**No manual configuration needed!**
