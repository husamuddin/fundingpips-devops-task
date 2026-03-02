include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//eks"
}

dependency "vpc" {
  config_path = "../main-vpc"
}

inputs = {
  name               = values.name
  kubernetes_version = values.kubernetes_version

  endpoint_public_access                   = values.endpoint_public_access
  endpoint_private_access                  = values.endpoint_private_access
  enable_cluster_creator_admin_permissions = values.enable_cluster_creator_admin_permissions
  enable_irsa                              = values.enable_irsa

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnets

  eks_managed_node_groups = values.eks_managed_node_groups

  tags = values.tags
}

