# MProfile Infrastructure as Code

This repository hosts the Terragrunt live configuration for the MProfile platform. It orchestrates Terraform modules that provision AWS networking and Kubernetes components across the supported environments (currently `dev` and `staging`).

## Repository layout
- `infrastructure-live/`
  - `root.hcl` configures remote state in the S3 bucket `mprofile-terraform` and generates the shared AWS provider block.
  - `fake-crt-encoded.crt` is a placeholder certificate consumed by dependency mocks so plans can run without contacting real clusters.
  - `dev/`, `staging/` contain the live Terragrunt stacks for each environment:
    - `env.hcl` defines per-environment locals such as `region`, `project`, and user lists.
    - `vpc/terragrunt.hcl` sources the shared VPC module (`git@github.com:MJTI/terraform-aws-vpc.git?ref=0.1.4`).
    - `eks/terragrunt.hcl` deploys the EKS control plane via `git@github.com:MJTI/terraform-aws-eks.git?ref=0.1.5` and depends on the VPC outputs.
    - `eks-controllers/terragrunt.hcl` installs cluster add-ons from `git@github.com:MJTI/terraform-aws-eks-controllers.git?ref=0.2.7`, consuming both VPC and EKS outputs.
    - `eks-roles/terragrunt.hcl` provisions IAM roles for cluster access with `git@github.com:MJTI/terraform-aws-eks-iam-roles.git?ref=0.1.5`.

## Prerequisites
- Terragrunt (0.45+) and Terraform (1.3+) installed locally.
- AWS CLI configured with credentials that can manage the `mprofile-terraform` state bucket and create infrastructure in the target account.
- SSH access to the private module repositories under `git@github.com:MJTI/`.
- The S3 bucket `mprofile-terraform` must exist ahead of time; Terragrunt will not create it.

## Remote state and providers
`infrastructure-live/root.hcl` centralises remote state configuration. All stacks write to `s3://mprofile-terraform/<environment>/<module>/terraform.tfstate`, enabling isolated state files per environment and module. Terragrunt also generates `provider.tf` so every module inherits the AWS region from its locals.

## Typical workflow
1. Set your AWS profile or credentials, for example `export AWS_PROFILE=mprofile-dev`.
2. Change into the environment directory, e.g. `cd infrastructure-live/dev`.
3. Initialise the stack: `terragrunt run-all init`.
4. Review changes: `terragrunt run-all plan` (add `--terragrunt-include-external-dependencies` if you want dependency stacks planned automatically).
5. Apply the desired modules: either `terragrunt run-all apply` for the whole environment or run Terragrunt in each module directory (e.g. `terragrunt apply` inside `vpc/`).
6. To tear down, run `terragrunt run-all destroy` from the environment directory, starting with dependent modules such as controllers before destroying the cluster and VPC.

## Customising environments
- Update `env.hcl` to adjust region, project name, or the user lists that map into IAM roles.
- Dependency blocks in each module ensure outputs (VPC IDs, subnets, EKS cluster info, certificates) flow between components. Terragrunt mock outputs allow you to run `plan` locally even when dependencies are not yet provisioned.
- To add a new environment, copy an existing environment folder, update its `env.hcl`, and adjust any references (state bucket, users, etc.). The remote state key automatically reflects the new path, but ensure the state bucket policy allows access.

## Related modules
The live configuration depends on reusable Terraform modules maintained separately:
- `terraform-aws-vpc`
- `terraform-aws-eks`
- `terraform-aws-eks-controllers`
- `terraform-aws-eks-iam-roles`

Review those modules for variable definitions, outputs, and version upgrade notes before changing their references here.
