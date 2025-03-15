# Set common variables for the region. This is automatically pulled in in the root terragrunt.hcl configuration to
# configure the remote state bucket and pass forward to the child modules as inputs.
locals {
  aws_region = "us-west-2"
  cidr       = "10.125.0.0/16"
  eks_clus   = "blue"
}

# 25 networks in between allows 25 regions
# cidr = "10.100.0.0/16"   # dev
# cidr = "10.125.0.0/16"   # stg   
# cidr = "10.150.0.0/16"   # prod
