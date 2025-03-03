#!/bin/bash

# Function to display usage information and exit
usage() {
    cat <<EOF

Usage: source $0 <environment>

This script sets up and persists in the executing shell environment:
    - The AWS profile to use for the specified environment.
    - Using 'granted' assumes the role for the specified environment.
    - Selects the Terraform workspace for the specified environment.

Valid environments:
  dev          Setup the development environment.
  stg          Setup the staging environment.
  prod         Setup the production environment.
  management   Setup the management environment for administrative tasks.

Example:
  source $0 dev

Options:
  -h, --help   Display this help message and exit.

EOF
    exit 1
}

# If the first argument is -h or --help, or if no argument is given, show usage.
if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    usage
fi

WORKING_ENV=$1

# Validate that the provided environment is valid using a case statement.
case "$WORKING_ENV" in
  dev|stg|prod|management)
    ;;
  *)
    echo "Error: Invalid environment '$WORKING_ENV'"
    usage
    ;;
esac

# Indicate the environment being set up
echo "Setting up environment: $WORKING_ENV"

# Export AWS profile
echo "Exporting AWS profile: $WORKING_ENV"
export AWS_PROFILE=$WORKING_ENV

# Assume the role for the specified environment
echo "Using 'granted' to assume the role for environment: $WORKING_ENV"
assume "$WORKING_ENV"

# Select the Terraform workspace
echo "Selecting Terraform workspace: $WORKING_ENV"
terraform workspace select "$WORKING_ENV"

# Indicate completion
echo "Environment setup complete for: $WORKING_ENV"
