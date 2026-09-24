variable "account_ids" {
  description = "Organization account ids, from the management landing zone's `account_ids` output (plus the management account itself)."
  type = object({
    management = string
    tooling    = string
    security   = optional(string)
    stage      = optional(string)
    prod       = optional(string)
  })
}

variable "terraform_role_name" {
  description = "Name of the terraform deploy role, identical in every account."
  type        = string
  default     = "terraform-deploy"
}

variable "use_deploy_role" {
  description = "Assume the local terraform-deploy role. Set false for the first-ever apply, which creates that role."
  type        = bool
  default     = true
}

variable "additional_terraform_role_trusts" {
  description = "Extra IAM role ARNs allowed to assume this account's terraform-deploy role (e.g. Identity Center reserved roles, once their suffixes are known)."
  type        = list(string)
  default     = []
}
