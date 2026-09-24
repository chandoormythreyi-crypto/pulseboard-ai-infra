locals {
  project     = "pulseboard"
  environment = "management"
  managed_by  = "terraform"
  region      = "us-east-1"

  # Pin once known — terraform then refuses to run against any other account.
  management_account_id = "457899555868"

  # Member accounts are created by module.aws_org in this landing zone, so
  # every downstream reference uses the computed id — nothing is hardcoded.
  account_ids = { for name, acct in module.aws_org.accounts : name => acct.id }
}
