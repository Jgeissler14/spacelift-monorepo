# Data sources for looking up existing AWS resources

# Uncomment to automatically lookup default VPC
# data "aws_vpc" "default" {
#   default = true
# }

# Uncomment to automatically lookup subnets by VPC
# data "aws_subnets" "public" {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
#
#   filter {
#     name   = "map-public-ip-on-launch"
#     values = ["true"]
#   }
# }
#
# data "aws_subnets" "private" {
#   filter {
#     name   = "vpc-id"
#     values = [var.vpc_id]
#   }
#
#   filter {
#     name   = "map-public-ip-on-launch"
#     values = ["false"]
#   }
# }

# Lookup current AWS region
data "aws_region" "current" {}

# Lookup current AWS account
data "aws_caller_identity" "current" {}
