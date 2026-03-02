# reference from: https://github.com/aws-samples/manage-terraform-statefiles-in-aws-pipeline

resource "aws_dynamodb_table" "dynamodb_tfstate_lock" {
  name           = var.dynamodb_table_name
  hash_key       = var.hash_key
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  dynamic "attribute" {
    for_each = var.attribute
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  server_side_encryption {
    enabled = true
  }

  tags = var.tags
}

module "s3_bucket_backend" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.10"

  bucket = var.bucket_name

  # ACL + ownership
  acl = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  # Versioning
  versioning = {
    enabled = true
  }

  # Block all public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = var.tags
}
