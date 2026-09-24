module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.10.0"

  bucket = var.bucket_name

  versioning = {
    enabled = var.versioning
  }

  server_side_encryption_configuration = var.enable_encryption ? {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.sse_algorithm != "AES256" ? var.kms_master_key_id : null
      }
    }
  } : null

  block_public_acls       = var.block_public_access
  block_public_policy     = var.block_public_access
  ignore_public_acls      = var.block_public_access
  restrict_public_buckets = var.block_public_access

  attach_policy = var.attach_policy
  policy        = var.policy

  lifecycle_rule = var.lifecycle_rule

  logging = var.logging

  tags = var.tags
}
