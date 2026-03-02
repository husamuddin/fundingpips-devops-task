variable "role_name" {
  description = "IAM role name for GitHub Actions OIDC federation"
  type        = string
  default     = "github-actions-role"
}

variable "github_repo_subject" {
  description = "GitHub OIDC subject condition (for example: repo:org/repo:*)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}

