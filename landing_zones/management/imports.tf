# ── One-time imports of pre-existing resources ────────────────────────────────
#
# Identity Center was enabled by hand before terraform, which also created the
# AWS Organization plus a starter AdministratorAccess permission set, an Admin
# group and the csongor admin user. These already exist in this account, so
# terraform adopts them instead of recreating (which would ConflictException).
#
# Safe to delete this file after the first successful `terraform apply` — import
# blocks are no-ops once the objects are in state.
#
# Discovered values (account 457899555868 / instance ssoins-72236a6f17902470):
#   org id .............. o-3qoodbirm0
#   identity store ...... d-90667ea5b2
#   AdministratorAccess . ps-7223b2eef1ecfca6
#   Admin group ......... 44e894a8-1001-7048-eedd-5e1de3285f61
#   csongor membership .. 4458c4a8-2011-7054-37e1-4c1ea31979f1

import {
  to = module.aws_org.aws_organizations_organization.org
  id = "o-3qoodbirm0"
}

import {
  to = module.aws_sso.aws_ssoadmin_permission_set.permission_sets["AdministratorAccess"]
  id = "arn:aws:sso:::permissionSet/ssoins-72236a6f17902470/ps-7223b2eef1ecfca6,arn:aws:sso:::instance/ssoins-72236a6f17902470"
}

import {
  to = module.aws_sso.aws_ssoadmin_managed_policy_attachment.attachments["AdministratorAccess-arn:aws:iam::aws:policy/AdministratorAccess"]
  id = "arn:aws:iam::aws:policy/AdministratorAccess,arn:aws:sso:::permissionSet/ssoins-72236a6f17902470/ps-7223b2eef1ecfca6,arn:aws:sso:::instance/ssoins-72236a6f17902470"
}

import {
  to = module.aws_sso.aws_identitystore_group.groups["Admin"]
  id = "d-90667ea5b2/44e894a8-1001-7048-eedd-5e1de3285f61"
}

import {
  to = module.aws_sso.aws_identitystore_group_membership.existing_user_memberships["csongor-Admin"]
  id = "d-90667ea5b2/4458c4a8-2011-7054-37e1-4c1ea31979f1"
}

import {
  to = module.aws_sso.aws_ssoadmin_account_assignment.management_account_assignment["Admin"]
  id = "44e894a8-1001-7048-eedd-5e1de3285f61,GROUP,457899555868,AWS_ACCOUNT,arn:aws:sso:::permissionSet/ssoins-72236a6f17902470/ps-7223b2eef1ecfca6,arn:aws:sso:::instance/ssoins-72236a6f17902470"
}
