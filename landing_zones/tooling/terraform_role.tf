# `terraform-deploy` role in the tooling account. Trusted by the management
# deploy role (the role chain that drives every LZ), the management GitHub OIDC
# role, and any Identity Center reserved role passed in explicitly.

module "terraform_role" {
  source = "../../modules/aws_terraform_role"

  terraform_role_name = var.terraform_role_name

  terraform_role_allowed_assume_arns = concat(
    [
      "arn:aws:iam::${var.account_ids.management}:role/${var.terraform_role_name}",
    ],
    var.additional_terraform_role_trusts,
  )
}
