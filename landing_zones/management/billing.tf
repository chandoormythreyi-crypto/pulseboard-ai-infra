# ── Centralized root access for member accounts ───────────────────────────────
# Lets the management account manage (and delete) member-account root
# credentials without each account's root user finishing console setup.
resource "aws_iam_organizations_features" "root_access" {
  enabled_features = [
    "RootCredentialsManagement",
    "RootSessions",
  ]

  depends_on = [module.aws_org]
}

# ── Org-wide monthly hard limit ───────────────────────────────────────────────
resource "aws_budgets_budget" "org_hard_limit" {
  name         = "${local.project}-org-hard-limit"
  budget_type  = "COST"
  limit_amount = tostring(var.org_monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  dynamic "notification" {
    for_each = [
      { type = "ACTUAL", threshold = 50 },
      { type = "ACTUAL", threshold = 80 },
      { type = "FORECASTED", threshold = 100 },
      { type = "ACTUAL", threshold = 100 },
    ]

    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = notification.value.threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = notification.value.type
      subscriber_email_addresses = [var.billing_alert_email]
    }
  }
}

# ── Role AWS Budgets assumes to attach/detach the lock SCP ────────────────────
resource "aws_iam_role" "budgets_action" {
  name        = "BudgetsActionRole"
  description = "Assumed by AWS Budgets to apply/remove the budget-lock SCP."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "budgets.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = {
        StringEquals = { "aws:SourceAccount" = local.management_account_id }
      }
    }]
  })
}

resource "aws_iam_role_policy" "budgets_action" {
  name = "AllowSCPAttachDetach"
  role = aws_iam_role.budgets_action.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["organizations:AttachPolicy", "organizations:DetachPolicy"]
      Resource = "*"
    }]
  })
}

# ── SCP applied as the lock when the budget is exceeded ───────────────────────
# Denies everything in member accounts except break-glass principals: the
# management root user, SSO roles and OrganizationAccountAccessRole.
resource "aws_organizations_policy" "budget_lock" {
  name        = "BudgetHardLock"
  description = "Applied automatically by AWS Budgets when the org monthly limit is exceeded."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "DenyAllOnBudgetExceeded"
        Effect   = "Deny"
        Action   = ["*"]
        Resource = ["*"]
        Condition = {
          StringNotLike = {
            "aws:PrincipalARN" = [
              "arn:aws:iam::${local.management_account_id}:root",
              "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*",
              "arn:aws:iam::*:role/OrganizationAccountAccessRole",
            ]
          }
        }
      }
    ]
  })

  depends_on = [module.aws_org]
}

resource "aws_budgets_budget_action" "lock_on_exceeded" {
  budget_name        = aws_budgets_budget.org_hard_limit.name
  action_type        = "APPLY_SCP_POLICY"
  approval_model     = "AUTOMATIC"
  notification_type  = "ACTUAL"
  execution_role_arn = aws_iam_role.budgets_action.arn

  action_threshold {
    action_threshold_type  = "PERCENTAGE"
    action_threshold_value = 100
  }

  definition {
    scp_action_definition {
      # SCPs cannot target the management account.
      policy_id  = aws_organizations_policy.budget_lock.id
      target_ids = values(local.account_ids)
    }
  }

  subscriber {
    address           = var.billing_alert_email
    subscription_type = "EMAIL"
  }
}
