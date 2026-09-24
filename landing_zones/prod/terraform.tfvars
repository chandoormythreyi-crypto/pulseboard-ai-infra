account_ids = {
  management = "457899555868"
  tooling    = "585688243441"
  prod       = "222165865283"
}

# First-ever apply creates terraform-deploy, so it cannot assume it yet.
use_deploy_role = true

monthly_budget_usd  = 300
billing_alert_email = "csongor+pulseboardbilling@apexlab.io"

# Prod SSO admin allowed to assume the local terraform-deploy role, so the
# provider can run as terraform-deploy (the only principal the Workloads SCP
# permits to set the S3 account public-access block).
additional_terraform_role_trusts = [
  "arn:aws:iam::222165865283:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_a805d82b9517022f",
]

# ---- Network ----
vpc_cidr = "10.30.0.0/16"

# ---- RDS (PostgreSQL) — production-hardened ----
db_engine_version          = "16.4"
db_instance_class          = "db.t4g.medium"
db_allocated_storage       = 50
db_max_allocated_storage   = 200
db_backup_retention_period = 30
db_multi_az                = true
db_deletion_protection     = true
db_skip_final_snapshot     = false

# ---- Frontend ----
# ACM cert is created for these; add the DNS-validation CNAMEs in Cloudflare at
# apply time (see frontend_certificate_validation output).
frontend_aliases = ["pulseboard-ai.com", "www.pulseboard-ai.com"]
