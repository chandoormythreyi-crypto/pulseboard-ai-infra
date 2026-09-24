# permission sets
resource "aws_ssoadmin_permission_set" "permission_sets" {

  for_each = { for i in var.sso_permissions : i.name => i }

  name             = each.value.name
  description      = each.value.description
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  session_duration = each.value.session_duration
}

# account assignments to permission sets
resource "aws_ssoadmin_account_assignment" "account_assignments" {

  for_each = { for i in flatten(
    [for group in var.sso_groups : [
      for account in group.account_access : {
        name                = group.name
        account             = account
        permission_set_name = group.permission_set_name
      }
    ]]
  ) : "${i.name}-${i.account}" => i }

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn
  principal_id       = aws_identitystore_group.groups[each.value.name].group_id
  principal_type     = "GROUP"
  target_id          = var.org_accounts[each.value.account].id # aws_organizations_account.accounts[each.value.account].id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "management_account_assignment" {
  for_each = { for i in var.sso_groups : i.name => i if i.management_account_access }

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set_name].arn
  principal_id       = aws_identitystore_group.groups[each.value.name].group_id
  principal_type     = "GROUP"
  target_id          = var.aws_account_id
  target_type        = "AWS_ACCOUNT"
}

# custom permission
resource "aws_ssoadmin_permission_set_inline_policy" "inline_policies" {

  for_each = { for i in flatten(
    [for p in var.sso_permissions : [
      for cp in p.custom_policies : {
        name          = p.name
        custom_policy = cp
      }
    ]]
  ) : "${i.name}-${i.custom_policy}" => i }

  inline_policy      = each.value.custom_policy
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.name].arn
}

# managed permission
resource "aws_ssoadmin_managed_policy_attachment" "attachments" {

  for_each = { for i in flatten(
    [for p in var.sso_permissions : [
      for mp in p.managed_policies : {
        name           = p.name
        managed_policy = mp
      }
    ]]
  ) : "${i.name}-${i.managed_policy}" => i }

  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.value.managed_policy
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.name].arn
}
