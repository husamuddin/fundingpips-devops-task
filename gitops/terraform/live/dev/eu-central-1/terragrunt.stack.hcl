locals {
  units_path  = "${get_repo_root()}/gitops/terraform/catalog/units"
  bucket_name = "fundingpips-devops-task-terragrunt-state"

  current_dir = get_terragrunt_dir()
  parent_dir  = dirname(local.current_dir)
  root_dir    = dirname(local.parent_dir)

  env_files = [
    "${local.root_dir}/env.hcl",
    "${local.parent_dir}/env.hcl",
    "${local.current_dir}/env.hcl",

    "${local.root_dir}/region.hcl",
    "${local.parent_dir}/region.hcl",
    "${local.current_dir}/region.hcl",
  ]

  env = merge([
    for f in local.env_files : try(read_terragrunt_config(f).locals, {})
  ]...)
}

unit "terraform-backend" {
  source = "${local.units_path}/terraform-backend"
  path = "terraform-backend"

  values = {
    bucket_name = local.bucket_name
    tags        = try(local.env.tags, {})
  }
}

unit "container-registries" {
  source = "${local.units_path}/ecr"
  path = "container-registries"

  values = {
    name = "api"
    region = local.env.region
    tags   = try(local.env.tags, {})
  }
}

unit "github-workflows-ecr-oidc" {
  source = "${local.units_path}/github"
  path = "github-workflows-ecr-oidc"

  values = {
    github_subject = "repo:husamuddin/*"
    tags   = try(local.env.tags, {})
  }
}

unit "main-vpc" {
  source = "${local.units_path}/vpc"
  path = "main-vpc"

  values = {
    name = "main"
    cidr = "10.0.0.0/16"
    private_subnets = [for i in range(3) : cidrsubnet("10.0.0.0/16", 4, i)]
    public_subnets  = [for i in range(3) : cidrsubnet("10.0.0.0/16", 4, i + 3)]

    enable_nat_gateway   = true
    single_nat_gateway   = true
    enable_dns_hostnames = true

    public_subnet_tags = {
      "kubernetes.io/role/elb" = 1
    }

    private_subnet_tags = {
      "kubernetes.io/role/internal-elb" = 1
    }

    tags        = try(local.env.tags, {})
  }
}

unit "main-eks" {
  source = "${local.units_path}/eks"
  path   = "main-eks"

  values = {
    name               = "main-eks-cluster"
    kubernetes_version = "1.35"

    endpoint_public_access                   = true
    endpoint_private_access                  = true
    enable_cluster_creator_admin_permissions = true
    enable_irsa                              = true

    deletion_protection                      = true

    compute_config = {
      enabled    = true
      node_pools = ["general-purpose"]
    }

    eks_managed_node_groups = null

    tags               = try(local.env.tags, {})
  }
}


unit "secrets-manager-irsa" {
  source = "${local.units_path}/iam/irsa"
  path   = "secrets-manager-irsa"

  values = {
    name          = "secrets-manager-irsa-role"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "SecretsReadAccess"
          Effect = "Allow"

          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]

          Resource = [
            "arn:aws:secretsmanager:eu-central-1:239861161554:secret:argo-cd-github-app-ClJHmy*"
          ]
        }
      ]
    })

    namespace_service_accounts = ["external-secrets:secret-manager"]
    tags               = try(local.env.tags, {})
  }
}
