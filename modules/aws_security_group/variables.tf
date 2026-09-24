variable "name" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "ingress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), null)
    source_security_group_id = optional(string, null)
    self                     = optional(bool, false)
    description              = optional(string, null)
  }))

  validation {
    condition = alltrue([
      for rule in var.ingress_rules : (
        (rule.source_security_group_id != null && rule.cidr_blocks == null && rule.self == false) ||
        (rule.source_security_group_id == null && rule.self == false) ||
        (rule.source_security_group_id == null && rule.cidr_blocks == null && rule.self == true)
      )
    ])
    error_message = "You cannot specify both 'cidr_blocks', 'source_security_group_id', or 'self' in the same ingress rule."
  }
  validation {
    condition = alltrue([
      for rule in var.ingress_rules : (
        ((rule.source_security_group_id != null || rule.self == true) && rule.description != null) ||
        (rule.source_security_group_id == null && rule.self == false)
      )
    ])
    error_message = "You must specify a description if you have used source_security_group_id or self"
  }
}

variable "egress_rules" {
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), null)
    source_security_group_id = optional(string, null)
    self                     = optional(bool, false)
    description              = optional(string, null)
  }))

  validation {
    condition = alltrue([
      for rule in var.egress_rules : (
        (rule.source_security_group_id != null && rule.cidr_blocks == null && rule.self == false) ||
        (rule.source_security_group_id == null && rule.self == false) ||
        (rule.source_security_group_id == null && rule.cidr_blocks == null && rule.self == true)
      )
    ])
    error_message = "You cannot specify both 'cidr_blocks', 'source_security_group_id', or 'self' in the same egress rule."
  }
  validation {
    condition = alltrue([
      for rule in var.egress_rules : (
        ((rule.source_security_group_id != null || rule.self == true) && rule.description != null) ||
        (rule.source_security_group_id == null && rule.self == false)
      )
    ])
    error_message = "You must specify a description if you have used source_security_group_id or self"
  }
}
variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
}

variable "env" {
  type        = string
  description = "The environment (dev | staging | prod)."
}