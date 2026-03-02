include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//github"
}

inputs = {
  // example value: repo:your-org/your-repo:*
  github_repo_subject = values.github_subject
  tags                = values.tags
}
