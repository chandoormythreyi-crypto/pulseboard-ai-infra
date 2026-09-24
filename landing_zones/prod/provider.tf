provider "aws" {
  region = local.region

  allowed_account_ids = [var.account_ids.prod]

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

# CloudFront ACM certificates must live in us-east-1. This region already is
# us-east-1, but the aws_cloudfront module declares a us_east_1 provider alias,
# so we pass this explicitly.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  allowed_account_ids = [var.account_ids.prod]

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
