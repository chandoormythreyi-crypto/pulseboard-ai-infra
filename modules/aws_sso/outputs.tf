output "identity_store_groups" {
  description = "Map of identity store groups"
  value       = aws_identitystore_group.groups
}

output "identity_store_id" {
  description = "The identity store ID"
  value       = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

output "admin_group_id" {
  description = "Group ID for admin group (null until the group exists in state)."
  value       = try(aws_identitystore_group.groups[var.admin_group_name].group_id, null)
}

output "readonly_admin_group_id" {
  description = "Group ID for ReadonlyAdmin group (null until the group exists in state)."
  value       = try(aws_identitystore_group.groups["ReadonlyAdmin"].group_id, null)
}
