output "organization_id" {
  description = "Organization id."
  value       = module.aws_org.organization_id
}

output "org_accounts" {
  description = "Member accounts → id/email."
  value       = module.aws_org.accounts
}

output "account_ids" {
  description = "Member account name → id. Feed these into the other landing zones' tfvars."
  value       = local.account_ids
}

output "identity_store_id" {
  description = "Identity Store id of the Identity Center instance."
  value       = module.aws_sso.identity_store_id
}

output "admin_group_id" {
  description = "Group id of the Admin group."
  value       = module.aws_sso.admin_group_id
}

output "management_terraform_role_arn" {
  description = "ARN of the management-account terraform-deploy role."
  value       = module.terraform_role.role_arn
}

output "github_oidc_role_arn" {
  description = "ARN of the GitHub Actions OIDC role."
  value       = module.github_oidc.oidc_role_arn
}
