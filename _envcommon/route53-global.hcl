# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for route53. The common variables for each environment to
# deploy route53 are defined here. This configuration will be merged into the environment configuration
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
  common_tags   = local.global_vars.locals.common_tags
  domain_name   = local.global_vars.locals.domain_name # pnjlavtech.com
  eks_clus      = local.region_vars.locals.eks_clus # blue or green 
  eks_name      = local.global_vars.locals.eks_name # eks
  env           = local.environment_vars.locals.environment # dev
  module_ver    = local.region_vars.locals.route53_global_mod_ver #  Eg "v1.0.6--route53-global"
  region        = local.region_vars.locals.region
  region_code   = lookup(local.global_vars.locals.region_codes, local.region, "usw2")
  vpc_cidr      = local.region_vars.locals.cidr

  env_reg     = "${local.env}-${local.region_code}" # "dev-usw2"
  eks_fname   = "${local.env_reg}-eks-${local.eks_clus}" # "dev-usw2-eks-blue"

  tags = merge(local.common_tags, {
    Environment = local.env
    Region      = local.region_code
    Module      = "route53-global"
    ModuleTag   = local.module_ver
  })

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//route53-global"
}




# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------

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
  env                           = local.env
  mgmt_acct_id                  = "${get_env("AWS_ACCOUNT_ID_MGMT")}"
  non_prod_create_in_mgmnt_acct = true
  # aws_account_id                = "${get_aws_account_id()}"
}