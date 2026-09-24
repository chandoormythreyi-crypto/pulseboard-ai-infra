# `terraform-deploy` role in the management account.
#
# First apply trusts only principals that already exist — a trust policy naming
# a non-existent principal fails with MalformedPolicyDocument. The SSO reserved
# roles for the member accounts only exist after Identity Center has provisioned
# them, so they go in through `var.additional_terraform_role_trusts` on a second
# pass (see README, step 4).

module "terraform_role" {
  source = "../../modules/aws_terraform_role"

  terraform_role_name = var.terraform_role_name

  terraform_role_allowed_assume_arns = concat(
    [module.github_oidc.oidc_role_arn],
    var.additional_terraform_role_trusts,
  )
}

# Lets the management deploy role hop into every member account's deploy role,
# so one role chain drives all landing zones. These are resource ARNs in a
# permissions policy (not trust principals), so they are valid before the
# child roles exist.
resource "aws_iam_role_policy" "assume_child_terraform_roles" {
  name = "AllowAssumeChildTerraformRoles"
  role = module.terraform_role.role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = [for id in values(local.account_ids) : "arn:aws:iam::${id}:role/${var.terraform_role_name}"]
      },
      {
        Effect   = "Allow"
        Action   = ["sts:AssumeRole"]
        Resource = [for id in values(local.account_ids) : "arn:aws:iam::${id}:role/OrganizationAccountAccessRole"]
      },
    ]
  })
}
