module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.15"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access                   = var.endpoint_public_access
  endpoint_private_access                  = var.endpoint_private_access
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  enable_irsa                              = var.enable_irsa

  compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  eks_managed_node_groups = var.eks_managed_node_groups

  tags = var.tags
}
