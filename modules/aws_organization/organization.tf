# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_organization

resource "aws_organizations_organization" "org" {
  # https://docs.aws.amazon.com/organizations/latest/APIReference/API_EnableAWSServiceAccess.html
  aws_service_access_principals = var.service_access_principals
  enabled_policy_types          = var.enabled_policy_types
  feature_set                   = "ALL" # ALL or CONSOLIDATED_BILLING
}
