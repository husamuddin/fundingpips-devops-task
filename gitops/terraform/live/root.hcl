locals {
  # Automatically load region-level variables
  region_vars = try(
    read_terragrunt_config(find_in_parent_folders("region.hcl")),
    { locals = { region = "eu-central-1" } }
  )

  # Automatically load environment-level variables
  environment_vars = try(
    read_terragrunt_config(find_in_parent_folders("env.hcl")),
    { locals = {} }
  )

  aws_region     = try(local.region_vars.locals.region, "eu-central-1")
  backend_bucket = "fundingpips-devops-task-terragrunt-state"
}

# this is for enabling working with tflocal (localstack) for development
terraform_binary = get_env("TERRAFORM_BINARY", "terraform")

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.generated.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket       = local.backend_bucket
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    dynamodb_table = "tfstate-lock"
  }
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
}
EOF
}

inputs = merge(
  local.region_vars.locals,
  local.environment_vars.locals,
)
