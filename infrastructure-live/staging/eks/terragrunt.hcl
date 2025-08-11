terraform {
  source = "git@github.com:MJTI/terraform-aws-eks.git?ref=0.2.0"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_id                 = "mock_vpc_id"
    aws_subnet_private_ids = ["fakeid1", "fakeid2"]
  }
}

inputs = {
  env = include.env.locals.env

  aws_subnet_private_ids = dependency.vpc.outputs.aws_subnet_private_ids

  region = include.env.locals.region

  project = include.env.locals.project

  cluster_admin_access = include.env.locals.cluster_admin_access
}