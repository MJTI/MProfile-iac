terraform {
    source = "git@github.com:MJTI/terraform-aws-vpc.git?ref=0.1.4"
}

include "root" {
    path = find_in_parent_folders("root.hcl")
}

include "env" {
    path = find_in_parent_folders("env.hcl")
    expose = true
    merge_strategy = "no_merge"
}

inputs = {
    env = include.env.locals.env

    region = include.env.locals.region
}