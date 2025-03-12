# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/route53.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

# Configure the version of the module to use in this environment. This allows you to promote new versions one
# environment at a time (e.g., qa -> stage -> prod).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v1.0.6--route53-global"
}

dependency "vpc" {
  config_path = "../vpc"
  // skip_outputs = true
  mock_outputs = {
    vpc_id          = "	vpc-08f7169617628dd22"
  }
  // mock_outputs_allowed_terraform_commands = ["plan"]
}


inputs = {
  create_in_non_prod_account    = true
  non_prod_create_in_mgmnt_acct = true
  # aws_account_id                = "${get_aws_account_id()}"
  mgmt_acct_id                  = "${get_env("AWS_ACCOUNT_ID_MGMT")}"

  tags = merge(include.envcommon.locals.tags, 
    {"TfModuleTag" = "v1.0.6--route53-global"}
  )
}