variable "account_ids" {
  description = "Organization account ids, from the management landing zone's `account_ids` output (plus the management account itself)."
  type = object({
    management = string
    tooling    = string
    prod       = string
  })
}

variable "terraform_role_name" {
  description = "Name of the terraform deploy role, identical in every account."
  type        = string
  default     = "terraform-deploy"
}

variable "github_oidc_role_name" {
  description = "Management-account GitHub Actions OIDC role allowed to chain into this account's deploy role."
  type        = string
  default     = "pulseboard-management-github-actions-role"
}

variable "use_deploy_role" {
  description = "Assume the local terraform-deploy role. Set false for the first-ever apply, which creates that role."
  type        = bool
  default     = true
}

variable "additional_terraform_role_trusts" {
  description = "Extra IAM role ARNs allowed to assume this account's terraform-deploy role (e.g. Identity Center reserved roles)."
  type        = list(string)
  default     = []
}

variable "monthly_budget_usd" {
  description = "Monthly cost alert threshold for this account."
  type        = number
}

variable "billing_alert_email" {
  description = "Recipient of this account's budget alerts."
  type        = string
}

# ---- Network ----
variable "vpc_cidr" {
  description = "CIDR block for this environment's VPC."
  type        = string
}

# ---- RDS (PostgreSQL) ----
variable "db_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial allocated storage (GiB)."
  type        = number
}

variable "db_max_allocated_storage" {
  description = "Max autoscaling storage (GiB). 0 disables autoscaling."
  type        = number
}

variable "db_backup_retention_period" {
  description = "Automated backup retention in days."
  type        = number
}

variable "db_multi_az" {
  description = "Deploy the DB as Multi-AZ."
  type        = bool
}

variable "db_deletion_protection" {
  description = "Protect the DB from deletion."
  type        = bool
}

variable "db_skip_final_snapshot" {
  description = "Skip the final snapshot on destroy."
  type        = bool
}

# ---- Frontend (S3 + CloudFront) ----
variable "frontend_aliases" {
  description = "Custom domain names for the CloudFront distribution. An ACM cert is created when non-empty (DNS validation required)."
  type        = list(string)
  default     = []
}
