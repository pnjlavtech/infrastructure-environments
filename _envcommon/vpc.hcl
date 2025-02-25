# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for vpc. The common variables for each environment to
# deploy vpc are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load global-level variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables needed 
  cidr        = local.region_vars.locals.cidr
  company     = local.global_vars.locals.company
  common_tags = local.global_vars.locals.common_tags
  eks_clus    = local.region_vars.locals.eks_clus  # blue or green
  eks_name    = local.global_vars.locals.eks_name  # eks 
  env         = local.environment_vars.locals.environment # dev
  region      = local.region_vars.locals.region # us-west-2
  region_code = lookup(local.global_vars.locals.region_codes, local.region, "usw2")
  vpc_cidr    = local.cidr

  env_reg     = "${local.env}-${local.region_code}" # "dev-usw2"
  eks_fname   = "${local.env_reg}-" # "dev-usw2-eks-blue"

  tags = merge(local.common_tags, {
    Environment = local.env
    Region      = local.region_code
    Module      = "vpc"
  })

  # Expose the base source URL so different versions of the module can be deployed in different environment-regions. 
  # This is used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//vpc"
  // this would be needed if the repo was private
  // base_source_url = "git::https://jazzlyj:${gh_token}@github.com/pnjlavtech/terragrunt-infrastructure-modules.git//modules/vpc"

  //  Set cidr_subnet newbits and netnums values to be common across all environments
  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
    cidrsubnet(local.vpc_cidr, 6, 1),
    cidrsubnet(local.vpc_cidr, 6, 2),
  ]

  private_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 4),
    cidrsubnet(local.vpc_cidr, 6, 5),
    cidrsubnet(local.vpc_cidr, 6, 6),
  ]

  intra_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 7),
    cidrsubnet(local.vpc_cidr, 6, 8),
    cidrsubnet(local.vpc_cidr, 6, 9),
  ]

}

# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables that have to pass in to use the module. 
# This defines the parameters that are common across all environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cidr            = local.cidr
  intra_subnets   = local.intra_subnets
  name            = "${local.env_reg}-vpc"
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets
  intra_subnet_tags = {
    Environment         = "${local.env}"
    Fullname            = "${local.env_reg}-vpc-subnet-intra" 
    ModuleComponent     = "subnet"
    ModuleComponentType = "subnet-intra"
  }
  private_subnet_tags = {
    Environment                       = "${local.env}"
    Fullname                          = "${local.env_reg}-vpc-subnet-private" 
    ModuleComponent                   = "subnet"
    ModuleComponentType               = "subnet-private"
    "karpenter.sh/discovery"          = "${local.eks_fname}"
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    Environment              = "${local.env}"
    Fullname                 = "${local.env_reg}-vpc-subnet-public" 
    // "kubernetes.io/cluster/${local.eks_fname}" = "shared"
    "kubernetes.io/role/elb" = 1
    ModuleComponent          = "subnet"
    ModuleComponentType      = "subnet-public"
  }

}
