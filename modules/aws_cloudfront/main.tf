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
    acm_certificate_arn            = length(var.aliases) > 0 && var.create_certificate ? aws_acm_certificate.this[0].arn : null
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
