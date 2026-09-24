output "role_arn" {
  value = aws_iam_role.terraform_role.arn
}

output "role_name" {
  value = aws_iam_role.terraform_role.name
}