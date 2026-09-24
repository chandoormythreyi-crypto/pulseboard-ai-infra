account_ids = {
  management = "457899555868"
  tooling    = "585688243441"
  security   = "242126390843"
  stage      = "631245465535"
  prod       = "222165865283"
}

# First-ever apply creates terraform-deploy, so it cannot assume it yet.
use_deploy_role = false

# SSO admin reserved roles allowed to assume tooling terraform-deploy, so the
# backend (which assumes this role for state access) works from an SSO session.
additional_terraform_role_trusts = [
  "arn:aws:iam::457899555868:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_d9afb7b6789dcbaf", # management
  "arn:aws:iam::585688243441:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_aa9dacf9e06062bc", # tooling
  "arn:aws:iam::631245465535:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_e906a6eb829fa725", # stage
  "arn:aws:iam::222165865283:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_a805d82b9517022f", # prod
  "arn:aws:iam::242126390843:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_f950ef6396a27bdb", # security
]
