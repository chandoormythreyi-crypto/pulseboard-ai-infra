output "cloudfront_distribution_id" {
  description = "The identifier for the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "origin_access_control_id" {
  description = "The ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.this.id
}

output "certificate_validation_options" {
  description = "Certificate validation options for DNS configuration"
  value       = var.create_certificate && length(var.aliases) > 0 ? aws_acm_certificate.this[0].domain_validation_options : null
} 