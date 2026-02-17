#!/bin/bash
# Discovers root modules and tfvars files to create Spacelift stacks

set -e

# Get the repo root (3 levels up from this script)
REPO_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
ROOT_MODULES_DIR="$REPO_ROOT/root-modules"

# Initialize JSON array
stacks="{"

first_module=true

# Loop through each directory in root-modules/
for module_dir in "$ROOT_MODULES_DIR"/*; do
  if [ -d "$module_dir" ]; then
    module_name=$(basename "$module_dir")

    # Skip the spacelift-policies module (don't create a stack for the admin stack itself)
    if [ "$module_name" = "spacelift-policies" ]; then
      continue
    fi

    tfvars_dir="$module_dir/tfvars"

    # Check if tfvars directory exists
    if [ -d "$tfvars_dir" ]; then
      # Loop through each .tfvars file
      for tfvars_file in "$tfvars_dir"/*.tfvars; do
        if [ -f "$tfvars_file" ]; then
          tfvars_name=$(basename "$tfvars_file")
          stack_key="${module_name}-${tfvars_name%.tfvars}"

          # Add comma before each entry except the first
          if [ "$first_module" = true ]; then
            first_module=false
          else
            stacks="${stacks},"
          fi

          # Add stack entry
          stacks="${stacks}\"${stack_key}\":{\"module_name\":\"${module_name}\",\"project_root\":\"root-modules/${module_name}\",\"tfvars_file\":\"${tfvars_name}\"}"
        fi
      done
    fi
  fi
done

stacks="${stacks}}"

# Output JSON in format expected by external data source (all in one key)
jq -n --arg stacks "$stacks" '{"stacks": $stacks}'
