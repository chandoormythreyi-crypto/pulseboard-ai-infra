provider "aws" {
  region = local.region

  # Guardrail: refuse to run against anything but the org management account.
  allowed_account_ids = [local.management_account_id]

  default_tags {
    tags = {
      aws-apn-id  = "pc:4yvel29i3inqo110fetr4dydt"
      Environment = local.environment
      ManagedBy   = local.managed_by
      Project     = local.project
    }
  }
}
