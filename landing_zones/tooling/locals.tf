locals {
  project     = "pulseboard"
  environment = "tooling"
  managed_by  = "terraform"
  region      = "us-east-1"

  state_bucket_name = "${local.project}-tfstate-${var.account_ids.tooling}"

  deploy_role_arn = var.use_deploy_role ? "arn:aws:iam::${var.account_ids.tooling}:role/${var.terraform_role_name}" : null
}
