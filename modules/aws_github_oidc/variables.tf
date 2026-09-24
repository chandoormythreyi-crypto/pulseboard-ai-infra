variable "allowed_github_repositories" {
  type        = list(string)
  description = "The github organizations / repositories to trust"
}

variable "github_role_name" {
  type = string
}

variable "terraform_roles_allowed_to_assume_arns" {
  description = "List of ARNs allowed for the github oidc role to assume"
  type        = list(string)
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}
