# ── Shared terraform state ────────────────────────────────────────────────────
# Every landing zone (management, tooling, security, stage, prod) keeps its
# state object here; cross-account access comes from the bucket policy.

module "tfstate_bucket" {
  source = "../../modules/aws_s3"

  bucket_name         = local.state_bucket_name
  versioning          = true
  enable_encryption   = true
  sse_algorithm       = "AES256"
  block_public_access = true

  # Server access logging intentionally disabled — no dedicated log-sink bucket
  # for a Terraform-only state bucket. Trivy AVD-AWS-0089 is waived in
  # infra/.trivyignore.

  # Every landing zone's backend assumes the tooling terraform-deploy role
  # (same account as this bucket) for state access, so no cross-account grant
  # is needed — the policy only enforces TLS.
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${local.state_bucket_name}",
          "arn:aws:s3:::${local.state_bucket_name}/*",
        ]
        Condition = { Bool = { "aws:SecureTransport" = "false" } }
      },
    ]
  })

  lifecycle_rule = [
    {
      id     = "expire-noncurrent-versions"
      status = "Enabled"
      filter = { prefix = "" }

      noncurrent_version_expiration = { noncurrent_days = 90 }
    }
  ]

  tags = {
    Name    = local.state_bucket_name
    Purpose = "terraform-state"
  }
}
