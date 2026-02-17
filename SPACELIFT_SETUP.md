# Spacelift Setup Guide

This guide walks through setting up Spacelift for the Neo4j web application demo, including policy enforcement.

## Prerequisites

- [ ] Spacelift account (spacelift.io)
- [ ] AWS account with necessary resources (VPC, subnets, secrets)
- [ ] This repository connected to Spacelift
- [ ] AWS credentials configured in Spacelift

## Step 1: Connect Repository

1. Log into Spacelift
2. Go to **Source Code** → **VCS Integrations**
3. Connect your GitHub/GitLab account
4. Add this repository: `spacelift-monorepo`

## Step 2: Create AWS Integration (Recommended)

1. Go to **Settings** → **Cloud Integrations** → **AWS**
2. Click **Add Integration**
3. Choose **AWS IAM Role** (recommended) or **Access Keys**
4. Follow the wizard to create an IAM role with necessary permissions:
   - EC2 (VPC, subnets, security groups)
   - ECS (clusters, services, task definitions)
   - ECR (read access to existing repos)
   - ELB (ALB, target groups, listeners)
   - IAM (roles and policies for ECS)
   - CloudWatch (log groups)
   - Secrets Manager (read access)
   - Route53 (DNS records)

## Step 3: Create Policies

### 3.1 Create "Required Tags" Policy

1. Go to **Policies** → **Create Policy**
2. Name: `Required Tags`
3. Type: **Plan Policy**
4. Body: Copy from `spacelift-policies/required-tags.rego`
5. **This will DENY deployments missing required tags**

### 3.2 Create "Security Policy"

1. Go to **Policies** → **Create Policy**
2. Name: `Security Best Practices`
3. Type: **Plan Policy**
4. Body: Copy from `spacelift-policies/security-policy.rego`
5. **This will WARN about security issues (HTTP-only, open security groups)**

### 3.3 Create "Cost Control" Policy

1. Go to **Policies** → **Create Policy**
2. Name: `Cost Control`
3. Type: **Plan Policy**
4. Body: Copy from `spacelift-policies/cost-control.rego`
5. **This will WARN about expensive configurations**

## Step 4: Create Stack for "Good Customer"

1. **Create Stack:**
   - Name: `neo4j-web-customer-good`
   - Space: `root` (or create a new space)
   - Repository: `spacelift-monorepo`
   - Branch: `main`
   - Project root: `root-modules/neo4j-web`

2. **Terraform Settings:**
   - VCS Provider: Choose your connected provider
   - Terraform version: `1.13.3`
   - Workflow tool: `terraform` (or `tofu`)

3. **Behavior:**
   - Administrative: ✅ (for demo purposes)
   - Autodeploy: ❌ (manual approval for demo)
   - Local Preview: ✅

4. **Environment Variables:**
   ```bash
   TF_CLI_ARGS_plan=-var-file=tfvars/customer-good.tfvars
   TF_CLI_ARGS_apply=-var-file=tfvars/customer-good.tfvars
   ```

5. **Attached Policies:**
   - ✅ Required Tags
   - ✅ Security Best Practices
   - ✅ Cost Control

6. **Cloud Integration:**
   - Attach the AWS integration you created

## Step 5: Create Stack for "Bad Customer"

Same as above, but:
- Name: `neo4j-web-customer-bad`
- Environment variables:
  ```bash
  TF_CLI_ARGS_plan=-var-file=tfvars/customer-bad.tfvars
  TF_CLI_ARGS_apply=-var-file=tfvars/customer-bad.tfvars
  ```

## Step 6: Update tfvars Files

Before triggering runs, update the tfvars files with your actual AWS resources.

### customer-good.tfvars

```hcl
# Update these values:
vpc_id             = "vpc-XXXXX"           # Your VPC ID
public_subnet_ids  = ["subnet-XXX", "subnet-YYY"]
private_subnet_ids = ["subnet-AAA", "subnet-BBB"]

acm_certificate_arn = "arn:aws:acm:..."   # Your ACM cert
frontend_domain     = "neo4j.yourdomain.com"
backend_domain      = "neo4j-api.yourdomain.com"
route53_zone_id     = "Z1234567890ABC"

backend_secrets = {
  NEO4J_PASSWORD = "arn:aws:secretsmanager:us-east-1:...:secret:..."
  OPENAI_API_KEY = "arn:aws:secretsmanager:us-east-1:...:secret:..."
}
```

### customer-bad.tfvars

```hcl
# Update these values (same VPC/subnets as good):
vpc_id             = "vpc-XXXXX"
public_subnet_ids  = ["subnet-XXX", "subnet-YYY"]
private_subnet_ids = ["subnet-AAA", "subnet-BBB"]

# Keep these commented out (HTTP-only, insecure):
# acm_certificate_arn = ""
# frontend_domain     = ""
# backend_domain      = ""

backend_secrets = {
  NEO4J_PASSWORD = "arn:aws:secretsmanager:us-east-1:...:secret:..."
}
```

## Step 7: Demo Flow

### Part 1: Show the "Bad Customer" Failing Policies

1. Open `neo4j-web-customer-bad` stack
2. Click **Trigger** → **Plan**
3. **Expected Results:**
   - ❌ Plan will FAIL due to "Required Tags" policy
   - Show the policy violations in the UI
   - Point out missing: Environment, Owner, CostCenter, DataSensitivity, BackupPolicy, Compliance tags
   - ⚠️ Warnings about HTTP-only (no HTTPS)
   - ⚠️ Warnings about single task (no HA)

### Part 2: Fix the Issues

Option A: Update customer-bad.tfvars to add the missing tags
Option B: Switch to customer-good.tfvars

### Part 3: Show the "Good Customer" Passing

1. Open `neo4j-web-customer-good` stack
2. Click **Trigger** → **Plan**
3. **Expected Results:**
   - ✅ Plan SUCCEEDS - all policies pass
   - All required tags present
   - HTTPS configured
   - HA configuration (2+ tasks)
4. Click **Confirm** to deploy

### Part 4: Show Audit Trail

1. Go to **Runs** tab
2. Show the history of runs
3. Show policy evaluation results
4. Show state changes
5. Highlight the approval workflow

## Video Talking Points

**Opening:**
"AI can generate infrastructure code in seconds, but without proper governance, it can create security vulnerabilities, compliance violations, and cost overruns."

**During Bad Customer Demo:**
"Here's infrastructure generated by AI. It looks fine at first glance, but watch what happens when we run it through Spacelift..."

**During Policy Failures:**
"Spacelift caught several issues:
- Missing required tags for cost tracking and compliance
- Using insecure HTTP instead of HTTPS
- Single instance with no high availability
- These would have made it to production without governance"

**After Fixing:**
"Now we've fixed the issues based on the policy feedback. The good customer configuration passes all our checks."

**Closing:**
"AI accelerates development, but Spacelift provides the guardrails: automated policy enforcement, audit trails, and approval workflows. This is how you safely leverage AI in production."

## Troubleshooting

### Issue: Stack won't initialize

- Check that Terraform version matches (1.13.3)
- Verify AWS credentials are attached
- Check that the project root path is correct

### Issue: Policies not triggering

- Ensure policies are attached to the stack
- Verify policy type is "Plan Policy"
- Check policy syntax in the Policies page

### Issue: AWS authentication errors

- Verify the IAM role has necessary permissions
- Check that the AWS integration is attached to the stack
- Test credentials in the stack's Environment page

### Issue: Module not found errors

- Ensure the repository path is correct
- Verify the branch is correct
- Check that child modules are in the repo

## Next Steps

After deployment:
1. Test the application via the ALB DNS name
2. Monitor CloudWatch logs
3. Test scaling by updating desired_count
4. Create additional customer stacks as needed
