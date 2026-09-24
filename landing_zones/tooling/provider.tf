provider "aws" {
  region = local.region

  allowed_account_ids = [var.account_ids.tooling]

  # Run as terraform-deploy so the deploy identity is the same no matter which
  # admin invokes terraform. This LZ creates that role, so the first-ever apply
  # runs without it — leave `deploy_role_arn` null for that run.
  dynamic "assume_role" {
    for_each = local.deploy_role_arn == null ? [] : [local.deploy_role_arn]

    content {
      role_arn = assume_role.value
    }
  }

  default_tags {
    tags = {
      aws-apn-id  = "pc:4yvel29i3inqo110fetr4dydt"
      Environment = local.environment
      ManagedBy   = local.managed_by
      Project     = local.project
    }
  }
}
