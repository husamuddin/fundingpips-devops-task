include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//ecs"
}

dependency "vpc" {
  config_path = "../main-vpc"
}

dependency "ecr_repository" {
  config_path = "../container-registry"
}

inputs = {
  name               = values.name
  region             = values.region
  domain_name        = values.domain_name
  cloudflare_zone_id = values.cloudflare_zone_id
  secrets            = values.secrets
  environment        = values.environment
  private_subnets    = dependency.vpc.outputs.private_subnets
  public_subnets     = dependency.vpc.outputs.public_subnets
  container_port     = values.container_port
  ecr_repository_url = dependency.ecr_repository.outputs.repository_url
  image_tag          = values.image_tag
  vpc_id             = dependency.vpc.outputs.vpc_id
  tags               = values.tags
}
