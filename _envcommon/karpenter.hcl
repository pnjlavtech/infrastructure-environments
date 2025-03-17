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
  module_ver  = local.region_vars.locals.karpenter_mod_ver #  Eg "v1.0.6--karpenter"
  region      = local.region_vars.locals.region
  region_code = lookup(local.global_vars.locals.region_codes, local.region, "usw2")

  env_reg     = "${local.env}-${local.region_code}" # "dev-usw2"
  eks_fname   = "${local.env_reg}-eks-${local.eks_clus}" # "dev-usw2-eks-blue"

  tags = merge(local.common_tags, {
    Environment = local.env
    RegionCode  = local.region_code
    Clustername = local.eks_fname
    Module      = "karpenter"
    ModuleTag   = local.module_ver
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

dependency "eks" {
  config_path = "${dirname(find_in_parent_folders())}/environments/${local.env}/${local.region}/eks"
  mock_outputs = {
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVW5JeVY4R2x0VXd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBMk1UY3dNalUwTURsYUZ3MHpOREEyTVRVd01qVTVNRGxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUN3bytiUFF1Nkk4MGMrUXh2QkIrOGJWcW56U2c2dmEzS1VmcEpuTHowT3l2RWNqcGJkMFdXaDh3dmEKUHBBdHB6NXdJSEg1Z1l2b3IzUjlyT3prR0tGSDhXUXRSZjBQRHNLR0N4NzNjd01OSTM1TFh6d0FldWpWR3hCTgpBRUwvaE5NOVIyREFsNEV0ZXZmeVMvNDkwTnF6a09acGNmQ25VUjV5ZFRFeHNpYTBhdnJVdmNkMG9Ib0VPaFcxCkpuc2ZVQ3RLTmRkWW5XK2VhSVFhVXdnYmIwSlFkTDRHOVBtZXpvRzIxLzl6c25YbTF5QjlqbWRuVXhPbGJhdUcKYnZEd2ZTbGxGSnNxVDNnRmUxL20ySW1RTnE5a1BxT0h3ckcyMHJtYWxsL0U5TFNpYkNPeUpyNER4Ym1zVURIZQpnUGNyVEN1eWFiN3doaXUxdXk1cUpTMk1lUkYxQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUWkl0TFhIQTNOcUJFTXNFeHl3UnowZXVmcjNEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmZVMVE4ME5JYQp2OWR1Y2JUZ0I2UUYybUpLSDZncHo0V0RLRmdaREt2QkxOcHhhRWFZNWZFdWZva3RkaGNnbFJqbWVIR0RtbGZyCis3N29yOUxIVjN3OVVVNGFLSlVuNjVBSmMxR2h0KzR5Z2VhcUw3OGV5VDAreUl2NHB6Z0dmZ3RHYVkyMjNTcjEKSDYvdjRJY2c5SXNGZXFFTDh0Y3d3TkZkcEZjQWpsdnF5OXF6am02VTVjY3hJZ1VISVUwK2xwejVCVmoyMVFOZgphcDNoeDRVLzY0bUgyVndtZmt0Skx1UHc4b3hjcy9QMjhxUDFjcnY1WFdRNEJUZmJSMnRidkp4WGYwdkxrK0FYCmZuU3RJdXVTWGhiRmJ5L0liVCtveEtLYkFKalc2dDBianpLTVFHRDNXaGNBZkpSYUgxNk42b2hXNDg3TUdMSlAKZlovdENtbGUra0ZWCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
    cluster_endpoint                   = "https://964C03D0934F8B3D97FBC6982BD906F4.gr7.us-west-2.eks.amazonaws.com"
    cluster_name                       = "eks"
  }
  // mock_outputs_allowed_terraform_commands = ["plan"]
}



inputs = {
  chart_version                      = "1.1.1"
  cluster_certificate_authority_data = dependency.eks.outputs.cluster_certificate_authority_data
  cluster_endpoint                   = dependency.eks.outputs.cluster_endpoint
  cluster_name                       = dependency.eks.outputs.cluster_name
  # env                                = local.env
}
