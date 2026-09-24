variable "terraform_role_name" {
  type = string
}

variable "terraform_role_allowed_assume_arns" {
  type = list(string)
}
