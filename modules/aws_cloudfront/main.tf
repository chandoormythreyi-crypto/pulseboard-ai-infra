terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# Policy for the app bucket to only allow access from CloudFront
resource "aws_s3_bucket_policy" "app_bucket_policy" {
  bucket = var.app_bucket_id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = ["s3:GetObject"]
        Resource = [
          "arn:aws:s3:::${var.app_bucket_id}/*"
        ]
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.this.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.description
  default_root_object = "index.html"
  aliases             = var.aliases

  # App S3 bucket origin
  origin {
    domain_name              = var.app_bucket_domain_name
    origin_id                = "app-s3-origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  # Default cache behavior for the app bucket
  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "app-s3-origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.app_cache_min_ttl
    default_ttl            = var.app_cache_default_ttl
    max_ttl                = var.app_cache_max_ttl
  }

  price_class = "PriceClass_100"

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = length(var.aliases) == 0 || !var.create_certificate
    acm_certificate_arn            = length(var.aliases) > 0 && var.create_certificate ? (local.dns_validate ? aws_acm_certificate_validation.this[0].certificate_arn : aws_acm_certificate.this[0].arn) : null
    ssl_support_method             = length(var.aliases) > 0 && var.create_certificate ? var.ssl_support_method : null
    minimum_protocol_version       = length(var.aliases) > 0 && var.create_certificate ? var.minimum_protocol_version : "TLSv1"
  }

  tags = merge(var.tags, { Name = "${var.name}-distribution" })
}

resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.env}-${var.name}-oac"
  description                       = "Origin Access Control for ${var.env}-${var.name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_acm_certificate" "this" {
  count             = var.create_certificate && length(var.aliases) > 0 ? 1 : 0
  provider          = aws.us_east_1
  domain_name       = var.aliases[0]
  validation_method = "DNS"

  subject_alternative_names = length(var.aliases) > 1 ? slice(var.aliases, 1, length(var.aliases)) : []

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, { Name = "${var.name}-certificate" })
}

locals {
  dns_validate = var.route53_zone_id != null && var.create_certificate && length(var.aliases) > 0
}

# Route53-managed ACM validation (only when a hosted zone is provided).
resource "aws_route53_record" "cert_validation" {
  for_each = local.dns_validate ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  count    = local.dns_validate ? 1 : 0
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# Point each alias at the distribution.
resource "aws_route53_record" "alias" {
  for_each = var.route53_zone_id != null ? toset(var.aliases) : toset([])

  zone_id = var.route53_zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
