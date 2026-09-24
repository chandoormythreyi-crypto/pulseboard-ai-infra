module "github_oidc" {
  source = "../../modules/aws_github_oidc"

  github_role_name = "${local.project}-${local.environment}-github-actions-role"

  allowed_github_repositories = var.allowed_github_repositories

  terraform_roles_allowed_to_assume_arns = concat(
    [module.terraform_role.role_arn],
    [for id in values(local.account_ids) : "arn:aws:iam::${id}:role/${var.terraform_role_name}"],
  )

  tags = {
    Name = "${local.project}-${local.environment}-github-oidc-provider"
  }
}
