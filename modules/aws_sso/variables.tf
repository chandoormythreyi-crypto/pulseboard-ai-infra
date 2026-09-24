variable "aws_account_id" {
  type = string
}

variable "org_accounts" {
  type = map(object({
    id = string
  }))
}

variable "sso_permissions" {
  type = list(object({
    name             = string
    description      = string
    managed_policies = list(string)
    custom_policies  = list(string)
    session_duration = string
  }))
}

variable "sso_groups" {
  type = list(object({
    name                      = string
    description               = string
    permission_set_name       = string
    management_account_access = bool
    account_access            = list(string)
  }))
}

variable "sso_users" {
  description = "Identity Center users terraform creates and owns."
  type = list(object({
    given_name        = string
    last_name         = string
    username          = string
    email             = string
    group_memberships = list(string)
  }))
  default = []
}

variable "admin_group_name" {
  type    = string
  default = "Administrator"
}

variable "existing_sso_users" {
  description = <<-EOT
    Identity Center users created outside terraform (e.g. by hand in the console,
    or synced from an external IdP) that still need group membership managed here.
    Looked up by user_name in the identity store; the user must already exist.
  EOT
  type = list(object({
    username          = string
    group_memberships = list(string)
  }))
  default = []
}
