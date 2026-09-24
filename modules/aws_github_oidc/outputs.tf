output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github.arn
}

output "oidc_role_arn" {
  value = aws_iam_role.github.arn
}

output "oidc_audience" {
  value = "sts.amazonaws.com"
}
