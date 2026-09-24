resource "aws_identitystore_group" "groups" {

  for_each = { for i in var.sso_groups : i.name => i }

  display_name      = each.value.name
  description       = each.value.description
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}
