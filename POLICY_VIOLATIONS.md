# Policy Violations Demo Matrix

This document shows exactly what violations will be caught for the video demo.

## Customer-Bad Violations

### ❌ DENY (Will Block Deployment)

| Policy | Resource | Violation | Why It Matters |
|--------|----------|-----------|----------------|
| Required Tags | All AWS resources | Missing: `Environment`, `Owner`, `CostCenter`, `DataSensitivity`, `BackupPolicy`, `Compliance` | Cost tracking, compliance auditing, data governance |

### ⚠️ WARN (Will Show Warnings)

| Policy | Resource | Warning | Impact |
|--------|----------|---------|---------|
| Security | ALB | No HTTPS listener configured | Traffic is unencrypted, vulnerable to MITM attacks |
| Security | ALB | Deletion protection disabled | ALB can be accidentally deleted |
| Cost Control | ECS Service (Frontend) | `desired_count = 1` | No high availability, single point of failure |
| Cost Control | ECS Service (Backend) | `desired_count = 1` | No high availability, single point of failure |

## Customer-Good (All Pass)

### ✅ COMPLIANT

| Policy | Check | Status |
|--------|-------|--------|
| Required Tags | All resources have: Environment=production, Owner=platform-team@acme.com, CostCenter=engineering, DataSensitivity=high, BackupPolicy=daily, Compliance=sox | ✅ PASS |
| Security | HTTPS with valid ACM certificate | ✅ PASS |
| Security | Deletion protection enabled | ✅ PASS |
| Cost Control | 2 frontend + 2 backend tasks (HA) | ✅ PASS |
| Cost Control | Reasonable resource allocation | ✅ PASS |

## Before/After Comparison

### Tags Comparison

**customer-bad.tfvars:**
```hcl
default_tags = {
  Project   = "demo"
  ManagedBy = "terraform"
}
# Missing: Environment, Owner, CostCenter, DataSensitivity, BackupPolicy, Compliance
```

**customer-good.tfvars:**
```hcl
default_tags = {
  Environment     = "production"
  Owner           = "platform-team@acme.com"
  CostCenter      = "engineering"
  Project         = "neo4j-knowledge-graph"
  ManagedBy       = "terraform"
  DataSensitivity = "high"
  BackupPolicy    = "daily"
  Compliance      = "sox"
}
```

### Security Comparison

**customer-bad.tfvars:**
```hcl
# No HTTPS - insecure HTTP only
acm_certificate_arn = ""  # Empty = HTTP only
frontend_domain     = ""
backend_domain      = ""
```

**customer-good.tfvars:**
```hcl
# HTTPS with proper certificate
acm_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
frontend_domain     = "graph.acme.com"
backend_domain      = "graph-api.acme.com"
```

### HA Comparison

**customer-bad.tfvars:**
```hcl
frontend_desired_count = 1  # Single instance
backend_desired_count  = 1  # Single instance
```

**customer-good.tfvars:**
```hcl
frontend_desired_count = 2  # HA configuration
backend_desired_count  = 2  # HA configuration
```

## Expected Spacelift Output

### customer-bad Stack - Plan Output

```
Planning...

Terraform will perform the following actions:

  # module.neo4j_web.aws_ecs_cluster.this[0] will be created
  # module.neo4j_web.aws_ecs_service.backend will be created
  # module.neo4j_web.aws_ecs_service.frontend will be created
  # module.neo4j_web.aws_lb.this will be created
  # ... (more resources)

Plan: 25 to add, 0 to change, 0 to destroy.

Policy Evaluation:

❌ DENIED by policy "Required Tags"
   - Resource 'module.neo4j_web.aws_ecs_cluster.this[0]' is missing required tags: ["Environment", "Owner", "CostCenter", "DataSensitivity", "BackupPolicy", "Compliance"]
   - Resource 'module.neo4j_web.aws_lb.this' is missing required tags: ["Environment", "Owner", "CostCenter", "DataSensitivity", "BackupPolicy", "Compliance"]
   - Resource 'module.neo4j_web.aws_ecs_service.backend' is missing required tags: ["Environment", "Owner", "CostCenter", "DataSensitivity", "BackupPolicy", "Compliance"]
   (... more resources ...)

⚠️ WARNING from policy "Security Best Practices"
   - ALB 'module.neo4j_web.aws_lb.this' does not have HTTPS listener configured - this is insecure
   - ALB 'module.neo4j_web.aws_lb.this' does not have deletion protection enabled

⚠️ WARNING from policy "Cost Control"
   - ECS Service 'module.neo4j_web.aws_ecs_service.frontend' has desired_count of 1 - consider HA configuration
   - ECS Service 'module.neo4j_web.aws_ecs_service.backend' has desired_count of 1 - consider HA configuration

This run has been REJECTED due to policy violations.
```

### customer-good Stack - Plan Output

```
Planning...

Terraform will perform the following actions:

  # module.neo4j_web.aws_ecs_cluster.this[0] will be created
  # module.neo4j_web.aws_ecs_service.backend will be created
  # module.neo4j_web.aws_ecs_service.frontend will be created
  # module.neo4j_web.aws_lb.this will be created
  # ... (more resources)

Plan: 27 to add, 0 to change, 0 to destroy.

Policy Evaluation:

✅ All policies passed!

✅ Required Tags - PASS
✅ Security Best Practices - PASS
✅ Cost Control - PASS

This run can be approved and applied.
```

## Demo Script

1. **"Let's deploy the AI-generated infrastructure"**
   - Trigger plan on customer-bad stack
   - Wait for policies to evaluate

2. **"Spacelift caught critical violations"**
   - Show missing tags
   - Show security issues (HTTP)
   - Show HA issues (single instance)

3. **"These would have caused problems in production:"**
   - No cost tracking (missing tags)
   - No compliance auditing (missing tags)
   - Insecure traffic (HTTP)
   - No resilience (single instance)

4. **"Let's fix it with the proper configuration"**
   - Trigger plan on customer-good stack
   - Show all policies passing

5. **"Now we can deploy with confidence"**
   - Approve and apply
   - Show audit trail
   - Show infrastructure deploying

6. **"This is how you safely use AI for infrastructure"**
   - AI generates the code quickly
   - Spacelift enforces governance
   - Platform team maintains control
   - Audit trail for compliance
