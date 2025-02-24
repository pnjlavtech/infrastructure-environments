# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  company       = "pnjlavtech"
  environment   = "dev"
  eks_name      = "eks" 
  public_domain = "dev.pnjlavtech.com"
}

# 25 networks in between allows 25 regions
# cidr = "10.100.0.0/16"   # dev
# cidr = "10.125.0.0/16"   # stg   
# cidr = "10.150.0.0/16"   # prod
