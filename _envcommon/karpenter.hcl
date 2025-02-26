# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for karpenter. The common variables for each environment to
# deploy karpenter are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load global-level variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  common_tags = local.global_vars.locals.common_tags
  eks_clus    = local.region_vars.locals.eks_clus
  eks_name    = local.global_vars.locals.eks_name
  env         = local.environment_vars.locals.environment
  region      = local.region_vars.locals.region
  region_code = lookup(local.global_vars.locals.region_codes, local.region, "usw2")

  env_reg     = "${local.env}-${local.region_code}" # "dev-usw2"
  eks_fname   = "${local.env_reg}-" # "dev-usw2-eks-blue"

  tags = merge(local.common_tags, {
    Environment = local.env
    Region      = local.region_code
    Clustername = local.eks_fname
    Module      = "karpenter"
  })


  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//karpenter"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------