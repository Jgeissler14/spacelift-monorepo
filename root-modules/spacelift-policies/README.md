# Spacelift Policy Administration

This directory contains Terraform code to manage Spacelift policies as infrastructure.

## What's Here

- `main.tf` - Terraform configuration for Spacelift policies
- `policies/` - Policy definitions in Rego format
  - `required-tags.rego` - DENIES deployments without required tags
  - `security-policy.rego` - DENIES HTTP-only ALBs, WARNS about security issues
  - `cost-control.rego` - WARNS about expensive/single-instance configs

## Option 1: Deploy Policies via Terraform (Recommended)

### Prerequisites

1. **Install Spacelift Provider:**

   ```bash
   terraform init
   ```

2. **Create Spacelift API Key:**
   - Log into Spacelift UI
   - Go to your profile → API Keys
   - Create new API key
   - Save the key ID and secret

3. **Set Environment Variables:**
   ```bash
   export SPACELIFT_API_KEY_ENDPOINT="https://yourorg.app.spacelift.io"
   export SPACELIFT_API_KEY_ID="01HXXXXXXXXXXXXXXXXXXXXXXX"
   export SPACELIFT_API_KEY_SECRET="your-secret-here"
   ```

### Deploy Policies

```bash
cd spacelift-admin

# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Create the policies
terraform apply
```

This will create all three policies in your Spacelift account.

### Attach Policies to Stacks

After creating policies, attach them to your stacks:

1. In Spacelift UI, go to your stack (e.g., `neo4j-web-customer-good`)
2. Go to **Policies** tab
3. Click **Attach Policy**
4. Select all three policies:
   - Required Tags
   - Security Best Practices
   - Cost Control

Repeat for both stacks (`customer-good` and `customer-bad`).

## Option 2: Create Policies Manually in Spacelift UI

If you prefer not to use Terraform:

### 1. Create "Required Tags" Policy

1. In Spacelift, go to **Policies** → **Create Policy**
2. Fill in:
   - **Name:** `Required Tags`
   - **Type:** `Plan`
   - **Labels:** `security`, `compliance`, `governance`
3. Copy/paste the contents of `policies/required-tags.rego` into the Body field
4. Click **Create**

### 2. Create "Security Best Practices" Policy

1. Go to **Policies** → **Create Policy**
2. Fill in:
   - **Name:** `Security Best Practices`
   - **Type:** `Plan`
   - **Labels:** `security`, `best-practices`
3. Copy/paste the contents of `policies/security-policy.rego` into the Body field
4. Click **Create**

### 3. Create "Cost Control" Policy

1. Go to **Policies** → **Create Policy**
2. Fill in:
   - **Name:** `Cost Control`
   - **Type:** `Plan`
   - **Labels:** `cost`, `optimization`
3. Copy/paste the contents of `policies/cost-control.rego` into the Body field
4. Click **Create**

### 4. Attach to Stacks

For each stack (`neo4j-web-customer-good` and `neo4j-web-customer-bad`):

1. Open the stack
2. Go to **Policies** tab
3. Click **Attach Policy**
4. Select all three policies
5. Save

## Testing Policies

### Test with customer-bad (should FAIL):

```bash
# In Spacelift UI:
1. Open "neo4j-web-customer-bad" stack
2. Click "Trigger" → "Plan"
3. Wait for plan to complete
4. Review policy evaluation results

Expected:
❌ DENIED by "Required Tags" policy
⚠️ WARNINGS from "Security Best Practices" policy
⚠️ WARNINGS from "Cost Control" policy
```

### Test with customer-good (should PASS):

```bash
# In Spacelift UI:
1. Open "neo4j-web-customer-good" stack
2. Click "Trigger" → "Plan"
3. Wait for plan to complete

Expected:
✅ All policies PASS
```

## Updating Policies

### If using Terraform:

1. Edit the `.rego` files in `policies/`
2. Run `terraform apply`
3. Policies will be updated in Spacelift

### If using UI:

1. Go to **Policies** in Spacelift
2. Click on the policy to edit
3. Update the Body
4. Save

## Policy Details

### Required Tags Policy (DENY)

**Enforces these tags on all resources:**

- `Environment` - e.g., production, staging, dev
- `Owner` - Email of the team/person responsible
- `CostCenter` - For cost allocation
- `DataSensitivity` - e.g., high, medium, low
- `BackupPolicy` - e.g., daily, weekly, none
- `Compliance` - e.g., sox, hipaa, none

**Why:** Cost tracking, compliance auditing, data governance

### Security Best Practices Policy (DENY + WARN)

**DENIES:**

- ALBs without HTTPS listeners (insecure)

**WARNS:**

- Security groups with 0.0.0.0/0 on non-standard ports
- ALBs without deletion protection

**Why:** Prevent security vulnerabilities and accidental deletions

### Cost Control Policy (WARN)

**WARNS:**

- ECS services with `desired_count < 2` (no HA)
- ECS tasks with CPU > 4 vCPUs
- ECS tasks with memory > 16 GB

**Why:** Cost optimization and availability best practices

## Troubleshooting

### Policy not triggering

- Verify the policy is attached to the stack
- Check that the policy type is "Plan"
- Review policy syntax in the Spacelift UI

### False positives

- Adjust the policy logic in the `.rego` files
- Add exceptions for specific resource types if needed

### Need to bypass a policy temporarily

- You can override policy decisions in Spacelift UI during approval
- Consider if the policy needs adjustment vs one-time bypass
