output "access_analyzer_arn" {
  description = "ARN of the organization-scoped IAM Access Analyzer."
  value       = aws_accessanalyzer_analyzer.organization.arn
}

output "terraform_deploy_role_arn" {
  description = "ARN of the security-account terraform-deploy role."
  value       = module.terraform_role.role_arn
}
