variable "org_accounts" {
  type = map(object({
    email    = string
    org_unit = string
    tags     = optional(map(string), {})
  }))
}

variable "org_units" {
  type = map(object({
    parent = string
  }))
  description = "Setting the parent to null results in organization units attached to the organization root. Supports up to 5 level deep unit structure."
}

variable "delegated_administrators" {
  type = list(object({
    account           = string
    service_principal = string
  }))
  default = []
}

variable "service_access_principals" {
  type = list(string)
  default = [
    "account.amazonaws.com",
    "sso.amazonaws.com",
    "ram.amazonaws.com",
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "malware-protection.guardduty.amazonaws.com",
    "cost-optimization-hub.bcm.amazonaws.com",
    "iam.amazonaws.com",
  ]
}

variable "enabled_policy_types" {
  description = "List of organization policy types to enable."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]

  validation {
    condition = alltrue([
      for policy_type in var.enabled_policy_types :
      contains([
        "AISERVICES_OPT_OUT_POLICY",
        "BACKUP_POLICY",
        "RESOURCE_CONTROL_POLICY",
        "SERVICE_CONTROL_POLICY",
        "TAG_POLICY"
      ], policy_type)
    ])
    error_message = "Enabled policy types must be one of: AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY, RESOURCE_CONTROL_POLICY, SERVICE_CONTROL_POLICY, or TAG_POLICY."
  }
}

variable "scps" {
  description = "Provide policies for units or accounts, for root SCP use the other variable!"
  type = map(object({
    description = optional(string, null)
    policy      = string
    org_unit    = optional(string, null)
    account     = optional(string, null)
  }))
  default = {}
}

variable "root_scp" {
  description = "SCP policy for the organization root."
  type        = string
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/Resource/organizations_policy
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_deny-requested-region.html
  default = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEverything",
      "Effect": "Allow",
      "Action": ["*"],
      "Resource": ["*"]
    },
    {
      "Sid": "DenyLeavingOrganization",
      "Effect": "Deny",
      "Action": ["organizations:LeaveOrganization"],
      "Resource": ["*"]
    }
  ]
}
  EOT
}
