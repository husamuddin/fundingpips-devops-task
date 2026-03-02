include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//terraform-backend"
}

inputs = {
  bucket_name = values.bucket_name
  tags        = values.tags
}
