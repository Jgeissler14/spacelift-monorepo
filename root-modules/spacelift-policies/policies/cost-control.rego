package spacelift

# Warn about single-instance deployments (no HA)
warn[msg] {
  service := input.terraform.resource_changes[_]
  service.type == "aws_ecs_service"
  service.change.actions[_] != "delete"

  desired_count := service.change.after.desired_count
  desired_count < 2

  msg := sprintf(
    "ECS Service '%s' has desired_count=%v (single instance). Consider using 2+ instances for high availability.",
    [service.address, desired_count]
  )
}

# Warn about expensive ECS task CPU configurations
warn[msg] {
  task := input.terraform.resource_changes[_]
  task.type == "aws_ecs_task_definition"
  task.change.actions[_] != "delete"

  cpu := to_number(task.change.after.cpu)
  cpu > 4096

  msg := sprintf(
    "ECS Task '%s' has high CPU allocation (%v units / %v vCPUs). Verify this is necessary for your workload.",
    [task.address, cpu, cpu / 1024]
  )
}

# Warn about expensive ECS task memory configurations
warn[msg] {
  task := input.terraform.resource_changes[_]
  task.type == "aws_ecs_task_definition"
  task.change.actions[_] != "delete"

  memory := to_number(task.change.after.memory)
  memory > 16384

  msg := sprintf(
    "ECS Task '%s' has high memory allocation (%v MB / %v GB). Verify this is necessary for your workload.",
    [task.address, memory, memory / 1024]
  )
}

# Sample for Spacelift UI
sample := true
