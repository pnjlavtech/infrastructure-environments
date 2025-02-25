locals {
  applied_by   = "jayl"
  applied_date = formatdate("YYYY-MM-DD_HH:MM:SS", timestamp())
  company      = "pnjlavtech"
  eks_name     = "eks"
  managed_by   = "terraform"
  module_repo  = "tf-aws-modules"
  owner        = "devops"
  region_codes = {
    "us-east-1"      = "use1"
    "us-west-2"      = "usw2"
    "eu-west-1"      = "euw1"
    "ap-southeast-2" = "aps2"
  }

  common_tags = {
    AppliedBy   = local.applied_by
    AppliedDate = local.applied_date
    ManagedBy   = local.managed_by
    ModuleRepo  = local.module_repo
    Owner       = local.owner
  }
}