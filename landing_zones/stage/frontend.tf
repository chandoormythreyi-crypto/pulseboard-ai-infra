module "frontend_bucket" {
  source = "../../modules/aws_s3"

  bucket_name         = "${local.project}-${local.environment}-frontend"
  versioning          = true
  block_public_access = true # served privately via CloudFront OAC
  tags                = local.tags
}

module "frontend_cdn" {
  source = "../../modules/aws_cloudfront"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  name                   = "${local.project}-${local.environment}-frontend"
  description            = "PulseBoard ${local.environment} frontend"
  app_bucket_id          = module.frontend_bucket.bucket_name
  app_bucket_domain_name = "${module.frontend_bucket.bucket_name}.s3.${local.region}.amazonaws.com"

  aliases            = var.frontend_aliases
  create_certificate = length(var.frontend_aliases) > 0

  env  = local.env_slug
  tags = local.tags
}
