# PulseBoard AWS Landing Zone

Multi-account AWS foundation: `management`, `tooling`, `security`, `stage`, `prod`.
Region: `us-east-1`. State: shared S3 bucket `pulseboard-tfstate-585688243441` in the tooling account.

```
infra/
  modules/                 reusable building blocks
    aws_organization/      org, OUs, accounts, SCPs, delegated admins
    aws_sso/               Identity Center permission sets, groups, users, assignments
    aws_s3/                hardened bucket wrapper
    aws_terraform_role/    per-account `terraform-deploy` role
    aws_github_oidc/       GitHub Actions OIDC provider + role
  landing_zones/
    management/            org root: accounts, SCPs, Identity Center, budgets, OIDC
    tooling/               shared terraform state bucket, access-log bucket
    security/              delegated admin for org IAM Access Analyzer (free-tier only)
    stage/                 workload account baseline + budget
    prod/                  workload account baseline + budget
```

## Account / OU layout

| OU | Account | Purpose |
|---|---|---|
| (root) | management | Organizations, Identity Center, billing guardrails |
| Infrastructure | tooling | Terraform state, CI/CD plumbing |
| Security | security | Delegated administrator for organization IAM Access Analyzer |
| Workloads | stage | Pre-production workloads |
| Workloads | prod | Production workloads |
| Suspended | — | Parking OU for decommissioned accounts |

## Guardrails

- Root SCP: deny leaving the org, deny member-account root user, deny regions outside `allowed_regions`.
- Workloads SCP: deny disabling CloudTrail / Config / GuardDuty / Security Hub and deny removing the S3 account public-access block, except for `terraform-deploy` (preventive guardrail — those services are not enabled yet, but the SCP is in place for when they are).
- Org budget: alerts at 50/80/100%; at 100% actual AWS Budgets attaches a deny-all SCP to every member account (break-glass via management root, SSO roles, `OrganizationAccountAccessRole`).
- Per-account budgets in `stage` and `prod`.
- Account-level S3 public access block and default EBS encryption in every member account.

## Identity Center

The Identity Center **instance** cannot be created by terraform — enable it once in the
management account console (`us-east-1`). Everything else is managed in
`landing_zones/management/sso.tf`:

| Group | Permission set | Accounts |
|---|---|---|
| `Admin` | AdministratorAccess (+ Billing) | management, tooling, security, stage, prod |
| `Developer` | PowerUserAccess | stage |
| `ReadonlyAdmin` | ReadOnlyAccess (+ billing read) | stage, prod, security |

`csongor@apexlab.io` is placed in `Admin` via `admin_user` in `terraform.tfvars`.

- `manage_admin_user = false` (default): the user already exists in the identity store —
  the one you create by hand in the console — and terraform only manages its group
  membership. Create it with **user name `csongor`**, otherwise the lookup fails.
- `manage_admin_user = true`: terraform creates and owns the user record instead. Use this
  only if no user with that user name exists yet.

Local SSO profile once the assignment exists:

```bash
aws configure sso --profile pulseboard-management
```

## Cost

Everything here is free-tier only. No GuardDuty, Security Hub, AWS Config, org CloudTrail
or KMS keys — those were removed to keep the running cost at $0 for an idle org. The only
resources that can ever bill are S3 storage in the tooling state/access-log buckets
(fractions of a cent while idle) and action-enabled budgets beyond the first two per
account (none here). Enable the paid security services later by restoring
`security/guardduty.tf`, `security/securityhub.tf`, `management/cloudtrail.tf` and the
Config delegation in `management/org.tf` from git history.

## Bootstrap order

Each landing zone's first apply creates its own `terraform-deploy` role, so that run must
not try to assume it: `use_deploy_role = false` (already set in the checked-in tfvars) and
run with local state, then migrate.

1. **management** — enable Identity Center in the console, then:
   ```bash
   cd landing_zones/management
   terraform init -backend=false && terraform apply
   ```
   Creates the org, the four member accounts, OUs, SCPs, Identity Center assignments,
   budgets and the GitHub OIDC role. Note the `account_ids` and `organization_id` outputs.
2. **tooling** — fill `account_ids` in `terraform.tfvars`, `terraform apply`. Creates
   `pulseboard-tfstate-585688243441`. Then flip `use_deploy_role = true` and re-apply.
3. Migrate every landing zone onto the shared bucket:
   ```bash
   cp backend.hcl.example backend.hcl   # fill in the tooling account id
   terraform init -migrate-state -backend-config=backend.hcl
   ```
4. **security** — fill `account_ids`, apply, then flip `use_deploy_role = true` and
   re-apply. Creates the organization-scoped IAM Access Analyzer (free).
5. **stage**, **prod** — fill `account_ids`, apply, flip `use_deploy_role = true`, re-apply.
6. Second-pass trusts: once Identity Center has provisioned the reserved roles, add their
   ARNs to `additional_terraform_role_trusts` in each landing zone so admins can assume
   `terraform-deploy` directly. Find the suffixes with:
   ```bash
   aws iam list-roles --query "Roles[?starts_with(RoleName,'AWSReservedSSO_AdministratorAccess')].RoleName"
   ```
7. Widen the state-bucket policy: add `security`, `stage`, `prod` to
   `state_bucket_reader_accounts` in the tooling tfvars and re-apply.

A trust policy naming a principal that does not exist yet fails with
`MalformedPolicyDocument` — that is why steps 4, 6 and 7 are separate passes.

## Checks

```bash
for d in landing_zones/*/ ; do (cd "$d" && terraform init -backend=false >/dev/null && terraform validate); done
trivy config --severity HIGH,CRITICAL .
```
