# ── AWS IAM Identity Center ───────────────────────────────────────────────────
#
# The Identity Center *instance* itself cannot be created by terraform — enable
# it once in the management account console (Region us-east-1). Everything below
# (permission sets, groups, account assignments, memberships) is managed here.
#
# `var.manage_admin_user = false` (default) assumes the admin user already
# exists in the identity store (created by hand, or synced from an external
# IdP) and only manages its group membership. Flip it to `true` to have
# terraform own the user record instead.

module "aws_sso" {
  source = "../../modules/aws_sso"

  aws_account_id = local.management_account_id

  org_accounts = { for name, acct in module.aws_org.accounts : name => { id = acct.id } }

  sso_permissions = [
    {
      name        = "AdministratorAccess"
      description = "Full administrator access through SSO."
      managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
        "arn:aws:iam::aws:policy/job-function/Billing",
      ]
      custom_policies  = []
      session_duration = "PT12H"
    },
    {
      name        = "PowerUserAccess"
      description = "Build access without IAM/organizations administration."
      managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess",
      ]
      custom_policies  = []
      session_duration = "PT8H"
    },
    {
      name        = "ReadonlyAccess"
      description = "Readonly + billing-read access through SSO."
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess",
      ]
      custom_policies  = []
      session_duration = "PT12H"
    },
  ]

  sso_groups = [
    {
      name                      = "Admin"
      description               = "Platform administrators; admin everywhere including the management account."
      permission_set_name       = "AdministratorAccess"
      management_account_access = true
      account_access            = ["tooling", "security", "stage", "prod"]
    },
    {
      name                      = "Developer"
      description               = "Build access in the stage account."
      permission_set_name       = "PowerUserAccess"
      management_account_access = false
      account_access            = ["stage"]
    },
    {
      name                      = "ReadonlyAdmin"
      description               = "Readonly access in stage, prod and security."
      permission_set_name       = "ReadonlyAccess"
      management_account_access = false
      account_access            = ["stage", "prod", "security"]
    },
  ]

  admin_group_name = "Admin"

  sso_users = var.manage_admin_user ? [
    {
      given_name        = var.admin_user.given_name
      last_name         = var.admin_user.last_name
      username          = var.admin_user.username
      email             = var.admin_user.email
      group_memberships = ["Admin"]
    },
  ] : []

  existing_sso_users = var.manage_admin_user ? [] : [
    {
      username          = var.admin_user.username
      group_memberships = ["Admin"]
    },
  ]
}
