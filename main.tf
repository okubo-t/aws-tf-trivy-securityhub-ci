module "codepipeline" {
  source = "./modules/codepipeline"

  Account = {
    profile = "YOUR AWS ACCOUNT PROFILE NAME"
    region  = "ap-northeast-1"
  }

  # Project Prefix
  prefix = "prefix"

  # Environment Prefix
  env = "test"

  # Codecommit Repository Name
  repository_name = "trivy-securityhub-ci"
  # Branch Name
  branch_name = "master"

  # ECR Repository Name
  ecr_name = "trivy-securityhub-ci"
}
