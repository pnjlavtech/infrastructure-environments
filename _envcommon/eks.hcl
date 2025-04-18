# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for eks. The common variables for each environment to
# deploy eks are defined here. This configuration will be merged into the environment configuration
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
  module_ver    = local.region_vars.locals.eks_mod_ver #  Eg "v1.0.6--eks"
  region        = local.region_vars.locals.region
  region_code   = lookup(local.global_vars.locals.region_codes, local.region, "usw2")
  vpc_cidr      = local.region_vars.locals.cidr

  env_reg     = "${local.env}-${local.region_code}" # "dev-usw2"
  eks_fname   = "${local.env_reg}-eks-${local.eks_clus}" # "dev-usw2-eks-blue"

  route53_zone_zone_arn_keyint = "${local.region_code}-int.${local.env}.${local.domain_name}"
  route53_zone_zone_arn_keypub = "${local.region_code}.${local.env}.${local.domain_name}"

  tags = merge(local.common_tags, {
    Environment = local.env
    RegionCode  = local.region_code
    Clustername = local.eks_fname
    Module      = "eks"
    ModuleTag   = local.module_ver
  })

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//eks"
}




# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------

dependency "vpc" {
  config_path = "${dirname(find_in_parent_folders())}/environments/${local.env}/${local.region}/vpc"
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


dependency "route53-global" {
  config_path = "${dirname(find_in_parent_folders())}/environments/${local.env}/${local.region}/route53-global"
  mock_outputs = {
    route53_zone_zone_arn = {
      (local.route53_zone_zone_arn_keyint) = "arn:aws:route53:::hostedzone/ABCDEFG1234"
      (local.route53_zone_zone_arn_keypub) = "arn:aws:route53:::hostedzone/HIJKLMN5678"
    }
  }

}





inputs = {
  domain_name           = "${local.region_code}.${local.env}.${local.domain_name}"
  eks_cluster_version   = "1.3.1"
  eks_fname             = local.eks_fname
  env                   = local.env
  intra_subnets         = dependency.vpc.outputs.intra_subnets
  private_subnets       = dependency.vpc.outputs.private_subnets
  route53_zone_zone_arn = dependency.route53-global.outputs.route53_zone_zone_arn["${local.region_code}.${local.env}.${local.domain_name}"]
  vpc_id                = dependency.vpc.outputs.vpc_id
}