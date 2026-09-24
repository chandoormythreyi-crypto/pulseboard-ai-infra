locals {
  project     = "pulseboard"
  environment = "stage"
  managed_by  = "terraform"
  region      = "us-east-1"

  deploy_role_arn = var.use_deploy_role ? "arn:aws:iam::${var.account_ids.stage}:role/${var.terraform_role_name}" : null
}
