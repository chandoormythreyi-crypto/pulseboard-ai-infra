variable "account_emails" {
  description = "Root email per member account. Each must be globally unique across AWS; AWS sends a verification mail to it."
  type = object({
    tooling  = string
    security = string
    stage    = string
    prod     = string
  })
}

variable "admin_user" {
  description = "Identity Center user granted the Admin group (AdministratorAccess in every account)."
  type = object({
    given_name = string
    last_name  = string
    username   = string
    email      = string
  })
}

variable "manage_admin_user" {
  description = "true: terraform creates the Identity Center user record. false (default): the user already exists in the identity store and terraform only manages its group membership."
  type        = bool
  default     = false
}

variable "billing_alert_email" {
  description = "Recipient of budget alerts (50/80/100%) and SCP-lock notifications."
  type        = string
}

variable "org_monthly_budget_usd" {
  description = "Org-wide monthly cost limit. At 100% actual, the BudgetHardLock SCP is attached to every member account."
  type        = number
  default     = 500
}

variable "allowed_regions" {
  description = "Regions member accounts may use. Enforced by the DenyUnapprovedRegions SCP; global services are exempted."
  type        = list(string)
  default     = ["us-east-1"]
}

variable "allowed_github_repositories" {
  description = "GitHub repos (org/repo:ref) allowed to assume the OIDC deploy role."
  type        = list(string)
  default     = []
}

variable "terraform_role_name" {
  description = "Name of the terraform deploy role, identical in every account."
  type        = string
  default     = "terraform-deploy"
}

variable "additional_terraform_role_trusts" {
  description = <<-EOT
    Extra IAM role ARNs allowed to assume the management terraform-deploy role.

    Empty on the first apply: the Identity Center reserved roles and the member
    account deploy roles do not exist yet, and naming a non-existent principal
    in a trust policy fails with MalformedPolicyDocument. Add them on a second
    pass, e.g.
      arn:aws:iam::<management_id>:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_<suffix>
  EOT
  type        = list(string)
  default     = []
}
