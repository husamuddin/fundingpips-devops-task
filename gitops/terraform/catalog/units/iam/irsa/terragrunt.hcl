include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//iam/irsa"
}

dependency "eks" {
  config_path = "../main-eks"
}


inputs = {
  name   = values.name
  policy = values.policy
  oidc_providers = {
    eks = {
      provider_arn = dependency.eks.outputs.oidc_provider_arn
      namespace_service_accounts = values.namespace_service_accounts
    }
  }

  tags        = values.tags
}

