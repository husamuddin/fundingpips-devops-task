include "root" {
  path = find_in_parent_folders("live/root.hcl")
}

terraform {
  source = "${find_in_parent_folders("catalog/modules")}//vpc"
}

inputs = {
  name = values.name
  vpc_cidr = values.cidr
  private_subnets = values.private_subnets
  public_subnets  = values.public_subnets

  enable_nat_gateway   = values.enable_nat_gateway
  single_nat_gateway   = values.single_nat_gateway
  enable_dns_hostnames = values.enable_dns_hostnames

  public_subnet_tags = values.public_subnet_tags
  private_subnet_tags = values.private_subnet_tags

  tags        = values.tags
}

