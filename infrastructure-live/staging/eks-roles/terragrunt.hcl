terraform {
  source = "git@github.com:MJTI/terraform-aws-eks-iam-roles.git?ref=0.2.1"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path           = find_in_parent_folders("env.hcl")
  expose         = true
  merge_strategy = "no_merge"
}

dependency "eks" {
  config_path = "../eks"

  mock_outputs = {
    cluster_name           = "fake_cluster_name"
    eks_host               = "https://mock"
    cluster_ca_certificate = file(find_in_parent_folders("fake-crt-encoded.crt"))
  }
}

inputs = {
  region = include.env.locals.region

  env = include.env.locals.env

  project = include.env.locals.project

  eks_cluster_name = dependency.eks.outputs.cluster_name

  developer_users = include.env.locals.developer_users

  devops_users = include.env.locals.devops_users

  eks_host = dependency.eks.outputs.eks_host

  cluster_ca_certificate = dependency.eks.outputs.cluster_ca_certificate
}