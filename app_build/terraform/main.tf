module "build_pipe" {
  source           = "git::ssh://git@github.com/CyberGRX/terraform-aws-grx-codebuild.git?ref=v2.0.0"
  region           = var.region
  vpc_id           = data.terraform_remote_state.vpc.outputs.vpc_id[var.env]
  private_subnets  = data.terraform_remote_state.vpc.outputs.private_subnets[var.env]
  project_name     = "aws-codebuild-docker-images"
  create_pipe      = "yes"
  include_ecr      = "yes"
  env              = "core"
  build_image      = "aws/codebuild/standard:2.0"
  github_repo_name = "aws-codebuild-docker-images"

  parameter_list = [
    "/build/secrets/daedalus",
    "/codebuild/nexus/helm-password",
  ]

  providers = {
    aws.core = aws.core
  }
}

