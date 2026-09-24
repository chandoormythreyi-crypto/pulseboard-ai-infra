terraform {
  backend "s3" {
    bucket       = "pulseboard-tfstate-585688243441"
    key          = "landing_zones/tooling/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true

    # `assume_role.role_arn` supplied via -backend-config=backend.hcl.
    # The bucket is created by this landing zone: bootstrap it with local
    # state, then `terraform init -migrate-state -backend-config=backend.hcl`.
  }
}
