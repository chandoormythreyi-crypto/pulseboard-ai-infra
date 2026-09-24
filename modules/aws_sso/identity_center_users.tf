resource "aws_identitystore_user" "users" {

  for_each = { for i in var.sso_users : i.username => i }

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  display_name = "${each.value.given_name} ${each.value.last_name}"
  user_name    = each.value.username

  name {
    given_name  = each.value.given_name
    family_name = each.value.last_name
  }

  emails {
    primary = true
    type    = "work"
    value   = each.value.email
  }
}
