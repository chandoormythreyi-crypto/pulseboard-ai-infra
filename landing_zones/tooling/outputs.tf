output "tfstate_bucket_name" {
  description = "Shared terraform state bucket."
  value       = module.tfstate_bucket.bucket_name
}

output "tfstate_bucket_arn" {
  description = "ARN of the shared terraform state bucket."
  value       = module.tfstate_bucket.bucket_arn
}

output "terraform_deploy_role_arn" {
  description = "ARN of the tooling-account terraform-deploy role."
  value       = module.terraform_role.role_arn
}
