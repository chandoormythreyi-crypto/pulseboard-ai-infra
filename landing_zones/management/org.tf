module "aws_org" {
  source = "../../modules/aws_organization"

  org_accounts = {
    "tooling" = {
      email    = var.account_emails.tooling
      org_unit = "Shared"
      tags     = { AccountType = "tooling" }
    }
    "security" = {
      email    = var.account_emails.security
      org_unit = "Shared"
      tags     = { AccountType = "security" }
    }
    "stage" = {
      email    = var.account_emails.stage
      org_unit = "Workloads"
      tags     = { AccountType = "workload", Stage = "stage" }
    }
    "prod" = {
      email    = var.account_emails.prod
      org_unit = "Workloads"
      tags     = { AccountType = "workload", Stage = "prod" }
    }
  }

  # The management (org root / payer) account is not a member of any OU — it
  # always lives directly under the organization root and cannot be moved into
  # one. tooling + security sit under Shared; stage + prod under Workloads.
  org_units = {
    "Shared"    = { parent = null }
    "Workloads" = { parent = null }
    "Suspended" = { parent = null }
  }

  # Minimal, no-cost trusted-service set: org management, Identity Center,
  # resource sharing and IAM Access Analyzer. No Config / GuardDuty / Security
  # Hub — those are paid and intentionally left out.
  service_access_principals = [
    "account.amazonaws.com",
    "iam.amazonaws.com",
    "sso.amazonaws.com",
    "ram.amazonaws.com",
    "access-analyzer.amazonaws.com",
  ]

  # IAM Access Analyzer (organization scope) is free; the security account runs
  # it as the delegated administrator.
  delegated_administrators = [
    {
      account           = "security"
      service_principal = "access-analyzer.amazonaws.com"
    },
  ]

  # Organization-wide guardrails. The management account is always exempt from
  # SCPs, so break-glass stays possible.
  root_scp = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowEverything"
        Effect   = "Allow"
        Action   = ["*"]
        Resource = ["*"]
      },
      {
        Sid      = "DenyLeavingOrganization"
        Effect   = "Deny"
        Action   = ["organizations:LeaveOrganization"]
        Resource = ["*"]
      },
      {
        Sid      = "DenyMemberAccountRootUser"
        Effect   = "Deny"
        Action   = ["*"]
        Resource = ["*"]
        Condition = {
          StringLike = { "aws:PrincipalArn" = ["arn:aws:iam::*:root"] }
        }
      },
      {
        Sid    = "DenyUnapprovedRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*", "access-analyzer:*", "account:*", "acm:*", "aws-marketplace:*",
          "bedrock:*", "billing:*", "budgets:*", "ce:*", "chime:*", "cloudfront:*",
          "cur:*", "globalaccelerator:*", "health:*", "iam:*", "importexport:*",
          "kms:*", "license-manager:*", "notifications:*", "organizations:*",
          "pricing:*", "route53:*", "route53domains:*", "s3:GetAccountPublic*",
          "s3:ListAllMyBuckets", "s3:PutAccountPublic*", "shield:*", "sso:*",
          "sts:*", "support:*", "trustedadvisor:*", "waf-regional:*", "waf:*",
          "wafv2:*",
        ]
        Resource = ["*"]
        Condition = {
          StringNotEquals = { "aws:RequestedRegion" = var.allowed_regions }
        }
      },
    ]
  })

  scps = {
    "workloads-security-baseline" = {
      description = "Stops workload accounts disabling the org security baseline."
      org_unit    = "Workloads"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "DenySecurityServiceTampering"
            Effect = "Deny"
            Action = [
              "cloudtrail:DeleteTrail",
              "cloudtrail:StopLogging",
              "cloudtrail:UpdateTrail",
              "config:DeleteConfigurationRecorder",
              "config:DeleteDeliveryChannel",
              "config:StopConfigurationRecorder",
              "guardduty:DeleteDetector",
              "guardduty:DisassociateFromMasterAccount",
              "guardduty:UpdateDetector",
              "securityhub:DeleteMembers",
              "securityhub:DisableSecurityHub",
              "securityhub:DisassociateFromMasterAccount",
            ]
            Resource = ["*"]
            Condition = {
              ArnNotLike = {
                "aws:PrincipalARN" = "arn:aws:iam::*:role/${var.terraform_role_name}"
              }
            }
          },
          {
            Sid      = "DenyS3PublicAccessBlockRemoval"
            Effect   = "Deny"
            Action   = ["s3:PutAccountPublicAccessBlock"]
            Resource = ["*"]
            Condition = {
              ArnNotLike = {
                "aws:PrincipalARN" = "arn:aws:iam::*:role/${var.terraform_role_name}"
              }
            }
          },
        ]
      })
    }
  }
}
