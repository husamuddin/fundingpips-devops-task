include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//ecr"
}

inputs = {
  name   = values.name
  region = values.region
  tags   = values.tags
}
