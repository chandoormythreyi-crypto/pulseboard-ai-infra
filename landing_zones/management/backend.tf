terraform {
  backend "s3" {
    bucket       = "pulseboard-tfstate-585688243441"
    key          = "landing_zones/management/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

    # `assume_role.role_arn` (tooling-account terraform-deploy) is supplied via
    #   terraform init -backend-config=backend.hcl
    # because the tooling account id does not exist until the org is created.
    # Bootstrap order: apply this LZ with local state, apply tooling, then
    # `terraform init -migrate-state -backend-config=backend.hcl`.
  }
}
