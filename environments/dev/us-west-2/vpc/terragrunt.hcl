# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Include the root configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. 
# The envcommon configuration contains settings that are common for the component across all environments.
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/vpc.hcl"
  # Want to reference the variables from the included config in this configuration, so expose it.
  expose = true
}

# Configure the version of the module to use in this environment. 
# This allows promotion of new versions one environment-region at a time (e.g., dev-usw2 -> stg-usw2 -> prod-usw2).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v0.1.3--vpc"
}


# ---------------------------------------------------------------------------------------------------------------------
# To override any of the common parameters for this environment, specify any inputs.
# ---------------------------------------------------------------------------------------------------------------------

inputs = {
  tags = merge(include.envcommon.locals.tags, 
    {"ModuleTag" = "v0.1.3--vpc"}
  )
}