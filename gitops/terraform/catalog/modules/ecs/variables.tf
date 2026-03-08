variable "name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(any)
}

variable "public_subnets" {
  type = list(any)
}

variable "ecr_repository_url" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "container_port" {
  type = number
}

variable "secrets" {
  type    = list(any)
  default = []
}

variable "environment" {
  type    = list(any)
  default = []
}

variable "tags" {
  type = map(any)
}


