variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"
  type        = string
  default = "tfstate-lock"
}

variable "hash_key" {
  description = "Hash key for the DynamoDB table"
  type        = string
  default     = "LockID"
}

variable "read_capacity" {
  description = "Read capacity units for the DynamoDB table"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for the DynamoDB table"
  type        = number
  default     = 5
}

variable "attribute" {
  description = "List of attributes for the DynamoDB table"
  type = list(object({
    name = string
    type = string
  }))
  default = [
    {
      name = "LockID"
      type = "S"
    }
  ]
}

variable "bucket_name" {
  description = "Name of the S3 bucket for Terraform state storage"
  type        = string
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = {}
}