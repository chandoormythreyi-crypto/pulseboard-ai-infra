output "accounts" {
  value = { for k, v in aws_organizations_account.accounts : k => {
    id    = v.id
    email = v.email # var.org_accounts[k].email
  } }
}

output "organization_id" {
  description = "The organization id (o-xxxxxxxxxx)."
  value       = aws_organizations_organization.org.id
}

output "organization_root_id" {
  description = "The organization root id (r-xxxx)."
  value       = aws_organizations_organization.org.roots[0].id
}

output "org_units" {
  description = "Map of organizational unit name → { id, arn }."
  value       = { for k, v in local.merged_org_units : k => { id = v.id, arn = v.arn } }
}
