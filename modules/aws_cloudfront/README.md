# AWS CloudFront Module

This module creates a CloudFront distribution optimized for serving web applications from S3. It provides global content delivery, HTTPS enforcement, custom domain support with SSL certificates, and secure S3 access using Origin Access Control (OAC). The module is specifically designed for Single Page Applications (SPAs) with proper routing fallbacks.

## Resources Created

- **CloudFront Distribution**: Global CDN for fast content delivery with IPv6 support
- **Origin Access Control (OAC)**: Secure mechanism for CloudFront to access S3 bucket
- **S3 Bucket Policy**: Restricts bucket access to only the CloudFront distribution
- **ACM Certificate**: Optional SSL/TLS certificate for custom domains (created in us-east-1)
- **Custom Error Pages**: SPA-friendly error handling (404/403 redirects to index.html)

## Architecture

The module implements a secure and performant web application delivery architecture:
- **Global Edge Network**: CloudFront edge locations provide low-latency content delivery worldwide
- **Secure Origin Access**: OAC ensures S3 bucket is only accessible through CloudFront
- **HTTPS Enforcement**: All HTTP requests are automatically redirected to HTTPS
- **SPA Support**: Custom error responses handle client-side routing for modern web apps

## Example for module with related resources

```hcl
# S3 bucket for the web application
module "app_bucket" {
  source = "../modules/s3"

  bucket = "${var.env}-my-app-bucket"
  env    = var.env
  tags   = local.common_tags
}

# CloudFront distribution for the web application
module "app_cloudfront" {
  source = "../modules/cloudfront"
  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  name                   = "${var.env}-my-app"
  description            = "CloudFront distribution for my web application"
  app_bucket_domain_name = "${module.app_bucket.bucket_name}.s3.amazonaws.com"
  app_bucket_id          = module.app_bucket.bucket_id
  aliases                = var.app_domain_names
  create_certificate     = var.app_create_certificate
  env                    = var.env
  tags                   = local.common_tags
  app_cache_min_ttl      = 0
  app_cache_default_ttl  = 3600
  app_cache_max_ttl      = 604800
}
```