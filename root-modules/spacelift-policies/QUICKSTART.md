# Spacelift Administrative Stack - Quick Start

This is a **stack-of-stacks** setup. One administrative stack manages everything.

## What This Creates

When you deploy this stack, it automatically creates:

✅ **3 Policies:**
- Required Tags (DENY)
- Security Best Practices (DENY + WARN)  
- Cost Control (WARN)

✅ **2 Infrastructure Stacks:**
- `neo4j-web-customer-good` (passes all policies)
- `neo4j-web-customer-bad` (fails policies - for demo)

✅ **Automatic Policy Attachments:**
- All 3 policies attached to both stacks

✅ **Environment Variables:**
- Each stack configured with correct tfvars file

## Setup (One-Time)

### 1. Create Spacelift API Key

1. Log into Spacelift
2. Your profile → **API Keys** → **Create**
3. Save the ID and Secret

### 2. Create THIS Administrative Stack (Only Manual Step!)

In Spacelift UI, create ONE stack:

- **Name**: `spacelift-admin`
- **Repository**: `spacelift-monorepo`
- **Branch**: `main`
- **Project root**: `root-modules/spacelift-policies`
- **Workflow tool**: `OpenTofu`
- **Terraform version**: `1.11.5`
- **Administrative**: ✅ YES (important!)

### 3. Set Environment Variables

In the `spacelift-admin` stack settings:

```bash
SPACELIFT_API_KEY_ENDPOINT=https://yourorg.app.spacelift.io
SPACELIFT_API_KEY_ID=01HXXX...
SPACELIFT_API_KEY_SECRET=xxx (mark as secret)
TF_VAR_github_namespace=yourorg
```

Optional (if you want AWS integration attached):
```bash
TF_VAR_aws_integration_id=01HXXX...
```

### 4. Deploy

1. Go to `spacelift-admin` stack
2. Click **Trigger** → **Plan**
3. Review: Creates 3 policies + 2 stacks
4. Click **Confirm**

### 5. Done! 

Now you have 3 stacks total:
- `spacelift-admin` (manages the other two)
- `neo4j-web-customer-good`
- `neo4j-web-customer-bad`

## Demo Flow

### Test Bad Customer (Fails)

1. Go to `neo4j-web-customer-bad` stack
2. Update `shared.auto.tfvars` with your VPC/subnets
3. Trigger plan
4. ❌ Watch it FAIL: Missing tags, HTTP-only, single instance

### Fix and Deploy Good Customer (Passes)

1. Go to `neo4j-web-customer-good` stack  
2. Trigger plan
3. ✅ Watch it PASS all policies
4. Confirm to deploy

## Making Changes

**To update policies or create more stacks:**

1. Edit files in `root-modules/spacelift-policies/`
2. Push to GitHub
3. Spacelift auto-triggers plan on `spacelift-admin`
4. Confirm to apply changes

**Everything is managed as code!** 🎉

## Architecture

```
spacelift-admin (this stack)
│
├── Creates Policies
│   ├── Required Tags
│   ├── Security Best Practices
│   └── Cost Control
│
└── Creates Infrastructure Stacks
    ├── neo4j-web-customer-good
    │   ├── Uses tfvars/customer-good.tfvars
    │   ├── Policies attached
    │   └── AWS integration attached
    │
    └── neo4j-web-customer-bad
        ├── Uses tfvars/customer-bad.tfvars
        ├── Policies attached
        └── AWS integration attached
```
