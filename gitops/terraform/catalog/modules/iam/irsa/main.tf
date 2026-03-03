resource "random_string" "random" {
  length           = 16
  special          = false
}

resource "aws_iam_policy" "this" {
  name        = "external-secrets-isra-${random_string.random.result}"
  policy      = var.policy
}

module "irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.4.0"

  name = var.name
  oidc_providers = var.oidc_providers

  policies = {
    external_secrets_policy = aws_iam_policy.this.arn
  }

  tags = var.tags
}
