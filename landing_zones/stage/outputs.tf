output "terraform_deploy_role_arn" {
  description = "ARN of this account's terraform-deploy role."
  value       = module.terraform_role.role_arn
}

output "db_address" {
  description = "RDS endpoint address."
  value       = module.rds.address
}

output "db_password_secret_arn" {
  description = "Secrets Manager ARN holding the DB master credentials (JSON)."
  value       = module.rds.connection_details_secret_arn
}

output "db_connection_string_secret_arn" {
  description = "Secrets Manager ARN holding the postgresql:// connection string."
  value       = module.rds.connection_string_secret_arn
}

output "frontend_bucket_name" {
  description = "S3 bucket backing the frontend CDN."
  value       = module.frontend_bucket.bucket_name
}

output "frontend_cloudfront_domain" {
  description = "CloudFront distribution domain name."
  value       = module.frontend_cdn.cloudfront_distribution_domain_name
}

output "frontend_cloudfront_distribution_id" {
  description = "CloudFront distribution id (for cache invalidations)."
  value       = module.frontend_cdn.cloudfront_distribution_id
}

output "route53_zone_id" {
  description = "Route53 hosted zone id for pulseboard.world."
  value       = aws_route53_zone.world.zone_id
}

output "route53_name_servers" {
  description = "Delegate the registrar's NS records to these to make Route53 authoritative."
  value       = aws_route53_zone.world.name_servers
}

output "dev_name_servers" {
  description = "Add these as NS records for dev.pulseboard.world in Cloudflare to delegate dev to Route53."
  value       = aws_route53_zone.dev.name_servers
}
