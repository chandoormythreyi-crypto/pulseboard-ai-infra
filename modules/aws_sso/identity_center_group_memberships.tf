resource "aws_identitystore_group_membership" "group_memberships" {

  for_each = { for i in flatten(
    [for user in var.sso_users : [
      for group in user.group_memberships : {
        username = user.username
        group    = group
      }
    ]]
  ) : "${i.username}-${i.group}" => i }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  group_id          = aws_identitystore_group.groups[each.value.group].group_id
  member_id         = aws_identitystore_user.users[each.value.username].user_id
}
