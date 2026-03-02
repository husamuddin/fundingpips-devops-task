variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  description = "Tags to apply to ECR resources"
  type        = map(string)
  default     = {}
}