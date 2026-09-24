output "repository_url" {
  description = "The URL of the repository"
  value       = aws_ecr_repository.this.repository_url
}

output "repository_arn" {
  description = "The ARN of the repository"
  value       = aws_ecr_repository.this.arn
}

output "repository_name" {
  description = "The name of the repository"
  value       = aws_ecr_repository.this.name
}

output "app_runner_role_arn" {
  description = "The ARN of the IAM role for App Runner"
  value       = aws_iam_role.app_runner_role.arn
}

output "app_runner_role_name" {
  description = "The name of the IAM role for App Runner"
  value       = aws_iam_role.app_runner_role.name
} 