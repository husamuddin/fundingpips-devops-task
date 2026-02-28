locals {
  units_path  = "${get_repo_root()}/terraform/catalog/units"
  bucket_name = "fundingpips-devops-task"

  current_dir = get_terragrunt_dir()
  parent_dir  = dirname(local.current_dir)
  root_dir    = dirname(local.parent_dir)

  env_files = [
    "${local.root_dir}/env.hcl",
    "${local.parent_dir}/env.hcl",
    "${local.current_dir}/env.hcl",
  ]

  env = merge([
    for f in local.env_files : try(read_terragrunt_config(f).locals, {})
  ]...)
}

unit "terraform-state" {
  source = "${local.units_path}/terraform-state"
  path   = "terraform-state"

  values = {
    bucket_name = local.bucket_name
    tags        = try(local.env.tags, {})
  }
}
