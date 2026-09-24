account_ids = {
  management = "457899555868"
  tooling    = "585688243441"
  stage      = "631245465535"
}

# First-ever apply creates terraform-deploy, so it cannot assume it yet.
use_deploy_role = true

monthly_budget_usd  = 150
billing_alert_email = "csongor+pulseboardbilling@apexlab.io"

# Stage SSO admin allowed to assume the local terraform-deploy role, so the
# provider can run as terraform-deploy (the only principal the Workloads SCP
# permits to set the S3 account public-access block).
additional_terraform_role_trusts = [
  "arn:aws:iam::631245465535:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_e906a6eb829fa725",
]

# ---- Network ----
vpc_cidr = "10.20.0.0/16"

# ---- RDS (PostgreSQL) ----
db_engine_version          = "16.4"
db_instance_class          = "db.t4g.micro"
db_allocated_storage       = 20
db_max_allocated_storage   = 50
db_backup_retention_period = 7
db_multi_az                = false
db_deletion_protection     = false
db_skip_final_snapshot     = true

# ---- Frontend ----
# ACM cert is created for these; add the DNS-validation CNAMEs in Cloudflare at
# apply time (see frontend_certificate_validation output).
frontend_aliases = ["staging.pulseboard.world"]
