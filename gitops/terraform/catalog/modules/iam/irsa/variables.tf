variable "name" {
  type = string
}

variable "oidc_providers" {
  type = any
  nullable = true
  default  = null
}

variable "policy" {
  type     = string
  nullable = true
}

variable "tags" {
  type = map(any)
  default  = {}
}
