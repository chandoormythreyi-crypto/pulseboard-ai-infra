# root SCP

resource "aws_organizations_policy" "root_policy" {
  name        = "organization-root-policy"
  description = "Root policy"
  content     = var.root_scp
  type        = "SERVICE_CONTROL_POLICY"

  depends_on = [aws_organizations_organization.org]
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment
resource "aws_organizations_policy_attachment" "root" {
  policy_id = aws_organizations_policy.root_policy.id
  target_id = aws_organizations_organization.org.roots[0].id
}

# other SCPs

resource "aws_organizations_policy" "scps" {

  for_each = var.scps

  name        = each.key
  description = each.value.description
  content     = each.value.policy
  type        = "SERVICE_CONTROL_POLICY"

  depends_on = [aws_organizations_organization.org]
}

# org unit attachments

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment
resource "aws_organizations_policy_attachment" "scps_to_org_units" {

  for_each = { for k, v in var.scps : k => v if v.org_unit != null }

  policy_id = aws_organizations_policy.scps[each.key].id
  target_id = local.merged_org_units[each.value.org_unit].id
}

# account attachments

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment
resource "aws_organizations_policy_attachment" "scps_to_org_accounts" {

  for_each = { for k, v in var.scps : k => v if v.account != null }

  policy_id = aws_organizations_policy.scps[each.key].id
  target_id = aws_organizations_account.accounts[each.value.account].id
}
