data "aws_identitystore_user" "existing" {

  for_each = { for i in var.existing_sso_users : i.username => i }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = each.value.username
    }
  }
}

resource "aws_identitystore_group_membership" "existing_user_memberships" {

  for_each = { for i in flatten(
    [for user in var.existing_sso_users : [
      for group in user.group_memberships : {
        username = user.username
        group    = group
      }
    ]]
  ) : "${i.username}-${i.group}" => i }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.groups[each.value.group].group_id
  member_id         = data.aws_identitystore_user.existing[each.value.username].user_id
}
