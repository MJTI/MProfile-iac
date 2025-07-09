terraform {
    source = "git@github.com:MJTI/terraform-aws-eks-controllers.git?ref=0.1.2"
}

include "root" {
    path = find_in_parent_folders("root.hcl")
}

include "env" {
    path = find_in_parent_folders("env.hcl")
    expose = true
    merge_strategy = "no_merge"
}

dependency "vpc" {
    config_path = "../vpc"

    mock_outputs = {
        vpc_id = "mock_vpc_id"
        aws_subnet_private_ids = [ "fakeid1", "fakeid2" ]
    }
}

dependency "eks" {
    config_path = "../eks"

    mock_outputs = {
        cluster_name = "fake_cluster_name"
        cluster_security_group_id = "fake_cluster_sg_id"
        eks_host = "https://mock"
        cluster_ca_certificate = file(find_in_parent_folders("fake-crt-encoded.crt"))
    }
}

inputs = {
  region = include.env.locals.region

  env = include.env.locals.env

  project = include.env.locals.project

  vpc_id = dependency.vpc.outputs.vpc_id

  aws_subnet_private_ids = dependency.vpc.outputs.aws_subnet_private_ids

  eks_cluster_name = dependency.eks.outputs.cluster_name

  cluster_security_group_id = dependency.eks.outputs.cluster_security_group_id

  eks_host = dependency.eks.outputs.eks_host

  cluster_ca_certificate = dependency.eks.outputs.cluster_ca_certificate
}