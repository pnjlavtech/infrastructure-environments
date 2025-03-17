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
  path   = "${dirname(find_in_parent_folders())}/_envcommon/eks.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

# Configure the version of the module to use in this environment-region. 
# Version set in the region.hcl allows most granular control of module version used in a env-reg.
# This allows promotion of new versions one environment-region at a time (e.g., dev-usw2 -> stg-usw2 -> prod-usw2).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v${include.envcommon.locals.module_ver}"
}


