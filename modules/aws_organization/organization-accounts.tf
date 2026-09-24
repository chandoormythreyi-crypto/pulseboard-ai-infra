# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account

resource "aws_organizations_account" "accounts" {

  for_each = var.org_accounts

  name                       = each.key
  email                      = each.value.email
  role_name                  = "OrganizationAccountAccessRole"
  iam_user_access_to_billing = "ALLOW" # "ALLOW" "DENY"

  parent_id = each.value.org_unit == null ? aws_organizations_organization.org.roots[0].id : local.merged_org_units[each.value.org_unit].id

  tags = each.value.tags
  # There is no AWS Organizations API for reading role_name
  lifecycle {
    # https://github.com/hashicorp/terraform-provider-aws/issues/12585
    ignore_changes = [role_name, iam_user_access_to_billing]
  }
}
