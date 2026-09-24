# `terraform-deploy` role in the prod account. Application infrastructure for
# this environment is deployed by this role from this landing zone.

module "terraform_role" {
  source = "../../modules/aws_terraform_role"

  terraform_role_name = var.terraform_role_name

  terraform_role_allowed_assume_arns = concat(
    [
      "arn:aws:iam::${var.account_ids.management}:role/${var.terraform_role_name}",
      "arn:aws:iam::${var.account_ids.tooling}:role/${var.terraform_role_name}",
      "arn:aws:iam::${var.account_ids.management}:role/${var.github_oidc_role_name}",
    ],
    var.additional_terraform_role_trusts,
  )
}
