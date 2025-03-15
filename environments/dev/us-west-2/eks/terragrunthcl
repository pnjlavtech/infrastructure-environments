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

# Configure the version of the module to use in this environment. This allows you to promote new versions one
# environment at a time (e.g., qa -> stage -> prod).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v1.0.0--eks"
}

dependency "vpc" {
  config_path = "../vpc"
  // skip_outputs = true
  mock_outputs = {
    vpc_id          = "	vpc-08f7169617628dd22"
    intra_subnets = [
             "subnet-0048819e19ca630b5", 
             "subnet-0d40e9b3d7602d3bb", 
             "subnet-08c154f3a5adccd99" 
    ]
    private_subnets = [
             "subnet-0037719e19ca630b5", 
             "subnet-0c40e9b3d7602d3aa", 
             "subnet-07c154f3a5adccd00" 
    ]
  }
  // mock_outputs_allowed_terraform_commands = ["plan"]
}


inputs = {
  eks_cluster_version = "1.3.1"
  vpc_id              = dependency.vpc.outputs.vpc_id
  intra_subnets       = dependency.vpc.outputs.intra_subnets
  private_subnets     = dependency.vpc.outputs.private_subnets
  tags                = merge(include.envcommon.locals.tags, 
    {"TfModuleTag" = "v1.0.0--eks"}
  )
}