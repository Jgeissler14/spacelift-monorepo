data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ecs_execution" {
  name               = "${var.project_name}-ecs-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role" "ecs_task" {
  name               = "${var.project_name}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "ecs_execution_base" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

locals {
  # Collect all secret ARNs, filtering out null and empty values
  # Use try() to handle cases where values might not be known at plan time
  secrets_arns = compact([
    for arn in concat(values(var.backend_secrets), values(var.frontend_secrets)) : 
    try(trimspace(arn), "") if try(trimspace(arn), "") != ""
  ])
  # Always create the policy resources to avoid count issues
  # If there are no secrets, the policy will just have an empty resources list
  has_secrets = true
}

resource "aws_iam_policy" "ecs_execution_secrets" {
  count = local.has_secrets ? 1 : 0
  name   = "${var.project_name}-ecs-exec-secrets"
  policy = data.aws_iam_policy_document.ecs_execution_secrets.json
}

data "aws_iam_policy_document" "ecs_execution_secrets" {
  # Only create statement if there are secrets
  dynamic "statement" {
    for_each = length(local.secrets_arns) > 0 ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue", "ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
      resources = local.secrets_arns
    }
  }
  
  # Fallback statement if no secrets (policy must have at least one statement)
  dynamic "statement" {
    for_each = length(local.secrets_arns) == 0 ? [1] : []
    content {
      effect    = "Deny"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets" {
  count      = local.has_secrets ? 1 : 0
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_execution_secrets[0].arn
}

resource "aws_iam_policy" "ecs_task_secrets" {
  count = local.has_secrets ? 1 : 0
  name   = "${var.project_name}-ecs-task-secrets"
  policy = data.aws_iam_policy_document.ecs_task_secrets.json
}

data "aws_iam_policy_document" "ecs_task_secrets" {
  # Only create statement if there are secrets
  dynamic "statement" {
    for_each = length(local.secrets_arns) > 0 ? [1] : []
    content {
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue", "ssm:GetParameters", "ssm:GetParameter", "ssm:GetParametersByPath"]
      resources = local.secrets_arns
    }
  }
  
  # Fallback statement if no secrets (policy must have at least one statement)
  dynamic "statement" {
    for_each = length(local.secrets_arns) == 0 ? [1] : []
    content {
      effect    = "Deny"
      actions   = ["secretsmanager:GetSecretValue"]
      resources = ["*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_secrets" {
  count      = local.has_secrets ? 1 : 0
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_secrets[0].arn
}
