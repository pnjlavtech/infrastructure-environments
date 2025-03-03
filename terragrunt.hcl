# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform/OpenTofu that provides extra tools for working with multiple modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account_name
  company      = local.global_vars.locals.company
  environment  = local.environment_vars.locals.environment
  region       = local.region_vars.locals.region
  region_code  = lookup(local.global_vars.locals.region_codes, local.region, "usw2")
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.region}"
  alias  = "${local.environment}" 

  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${get_aws_account_id()}", "${get_env("AWS_ACCOUNT_ID_MGMT")}"]
}

provider "aws" {
  region = "${local.region}"
  alias  = "aws.management" 

  assume_role {
    role_arn = "arn:aws:iam::${get_env("AWS_ACCOUNT_ID_MGMT")}:role/${local.environment}-cross-acct-management-role"
    session_name = "${local.environment}-assume-cross-acct-tf-session"
  }
  # Only these AWS Account IDs may be operated on by this template
  allowed_account_ids = ["${get_aws_account_id()}", "${get_env("AWS_ACCOUNT_ID_MGMT")}"]

}
EOF
}

# Removed from generate provider for now as it may block cross account access 
# and I dont want set up a bunch of code right now to add in the management account 
  ## Only these AWS Account IDs may be operated on by this template
  # allowed_account_ids = ["${get_aws_account_id()}"]



# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remote_state {
  backend = "s3"
  config = {
    encrypt        = true
    bucket         = "${local.company}-${local.environment}-${local.region_code}-tfstate-s3-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/tf.tfstate"
    region         = local.region
    dynamodb_table = "tf-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}


// The linting and SCA checks by tflint and checkov are done in the ghactions workflow and are not needed here



# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.global_vars.locals,
  local.environment_vars.locals,
  local.account_vars.locals,
  local.region_vars.locals,
)
