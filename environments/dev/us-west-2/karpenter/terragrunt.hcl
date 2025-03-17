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
  path   = "${dirname(find_in_parent_folders())}/_envcommon/karpenter.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

# Configure the version of the module to use in this environment-region. 
# Version set in the region.hcl allows most granular control of module version used in a env-reg.
# This allows promotion of new versions one environment-region at a time (e.g., dev-usw2 -> stg-usw2 -> prod-usw2).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v${include.envcommon.locals.module_ver}"
}


dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_certificate_authority_data = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJVW5JeVY4R2x0VXd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TkRBMk1UY3dNalUwTURsYUZ3MHpOREEyTVRVd01qVTVNRGxhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUN3bytiUFF1Nkk4MGMrUXh2QkIrOGJWcW56U2c2dmEzS1VmcEpuTHowT3l2RWNqcGJkMFdXaDh3dmEKUHBBdHB6NXdJSEg1Z1l2b3IzUjlyT3prR0tGSDhXUXRSZjBQRHNLR0N4NzNjd01OSTM1TFh6d0FldWpWR3hCTgpBRUwvaE5NOVIyREFsNEV0ZXZmeVMvNDkwTnF6a09acGNmQ25VUjV5ZFRFeHNpYTBhdnJVdmNkMG9Ib0VPaFcxCkpuc2ZVQ3RLTmRkWW5XK2VhSVFhVXdnYmIwSlFkTDRHOVBtZXpvRzIxLzl6c25YbTF5QjlqbWRuVXhPbGJhdUcKYnZEd2ZTbGxGSnNxVDNnRmUxL20ySW1RTnE5a1BxT0h3ckcyMHJtYWxsL0U5TFNpYkNPeUpyNER4Ym1zVURIZQpnUGNyVEN1eWFiN3doaXUxdXk1cUpTMk1lUkYxQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUWkl0TFhIQTNOcUJFTXNFeHl3UnowZXVmcjNEQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmZVMVE4ME5JYQp2OWR1Y2JUZ0I2UUYybUpLSDZncHo0V0RLRmdaREt2QkxOcHhhRWFZNWZFdWZva3RkaGNnbFJqbWVIR0RtbGZyCis3N29yOUxIVjN3OVVVNGFLSlVuNjVBSmMxR2h0KzR5Z2VhcUw3OGV5VDAreUl2NHB6Z0dmZ3RHYVkyMjNTcjEKSDYvdjRJY2c5SXNGZXFFTDh0Y3d3TkZkcEZjQWpsdnF5OXF6am02VTVjY3hJZ1VISVUwK2xwejVCVmoyMVFOZgphcDNoeDRVLzY0bUgyVndtZmt0Skx1UHc4b3hjcy9QMjhxUDFjcnY1WFdRNEJUZmJSMnRidkp4WGYwdkxrK0FYCmZuU3RJdXVTWGhiRmJ5L0liVCtveEtLYkFKalc2dDBianpLTVFHRDNXaGNBZkpSYUgxNk42b2hXNDg3TUdMSlAKZlovdENtbGUra0ZWCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K"
    cluster_endpoint                   = "https://964C03D0934F8B3D97FBC6982BD906F4.gr7.us-west-2.eks.amazonaws.com"
    cluster_name                       = "eks"
  }
  // mock_outputs_allowed_terraform_commands = ["plan"]
}


