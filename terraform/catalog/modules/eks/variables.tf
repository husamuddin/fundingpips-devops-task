variable "name" {
  type = string
}
variable "kubernetes_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "endpoint_public_access" {
  type = bool
  default = true
}

variable "endpoint_private_access" {
  type = bool
  default = true
}

variable "enable_cluster_creator_admin_permissions" {
  type = bool
  default = true
}

variable "enable_irsa" {
  type = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "eks_managed_node_groups" {
  type = map(any)
}
