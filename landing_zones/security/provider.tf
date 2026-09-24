provider "aws" {
  region = local.region

  allowed_account_ids = [var.account_ids.security]

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
