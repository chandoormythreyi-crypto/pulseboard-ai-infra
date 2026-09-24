# Copy the database into the stage account (one-time seed)

Goal: put a **copy** of the current data into the new stage-account RDS. This is
a point-in-time seed, not a cutover and not ongoing replication.

- **Source** (management account `457899555868`):
  `pulseboard-staging-db.cipi66i64ya9.us-east-1.rds.amazonaws.com:5432`,
  database `pulseboard_staging`.
- **Target** (stage account `631245465535`): the RDS created by
  `landing_zones/stage` (`module.rds`), database `pulseboard`, user `pulseboard`.
  Credentials are in Secrets Manager secret `pulseboard-stage` (JSON).

## Prerequisites

1. `terraform apply` of `landing_zones/stage` has run, so the target RDS + its
   `pulseboard-stage` secret exist. Get the endpoint:
   ```bash
   terraform -chdir=landing_zones/stage output -raw db_address
   ```
2. `psql` / `pg_dump` / `pg_restore` **16.x** locally.
3. Network reachability to both DBs. Both are in private subnets, so use SSM
   port-forwarding through an SSM-managed host in each VPC (no public exposure):
   ```bash
   # source -> localhost:5432  (run against a host in the management VPC)
   aws ssm start-session --profile mgmt \
     --target <mgmt-bastion-instance-id> \
     --document-name AWS-StartPortForwardingSessionToRemoteHost \
     --parameters '{"host":["pulseboard-staging-db.cipi66i64ya9.us-east-1.rds.amazonaws.com"],"portNumber":["5432"],"localPortNumber":["5432"]}'

   # target -> localhost:5433  (run against a host in the stage VPC)
   aws ssm start-session --profile stage \
     --target <stage-bastion-instance-id> \
     --document-name AWS-StartPortForwardingSessionToRemoteHost \
     --parameters '{"host":["<db_address>"],"portNumber":["5432"],"localPortNumber":["5433"]}'
   ```

## Run

```bash
# source creds (management account secret)
SRC=$(aws secretsmanager get-secret-value --profile mgmt \
  --secret-id pulseboard/staging/database_url --query SecretString --output text)

# target creds (stage account secret, JSON)
TGT=$(aws secretsmanager get-secret-value --profile stage \
  --secret-id pulseboard-stage --query SecretString --output text)
TGT_USER=$(jq -r .username <<<"$TGT"); TGT_PASS=$(jq -r .password <<<"$TGT")

SOURCE_DB_URL="postgresql://<src-user>:<src-pass>@localhost:5432/pulseboard_staging?sslmode=require" \
TARGET_DB_URL="postgresql://${TGT_USER}:${TGT_PASS}@localhost:5433/pulseboard?sslmode=require" \
  scripts/copy-db.sh
```

The script refuses to run if the target already contains tables, dumps with
`pg_dump --format=directory --no-owner --no-privileges` (so source roles like
`pulseboard_admin` don't need to exist in the target), restores, then prints the
top tables by row count.

## After the copy

Point the app at the stage DB by setting the app's `DATABASE_URL` secret to the
`pulseboard-stage` connection details. Re-run the copy any time to refresh the
seed — drop and recreate the `pulseboard` database first (the script won't
overwrite a populated target).

## Alternative: snapshot restore

For a full-fidelity copy you can instead share an encrypted RDS snapshot of the
source to the stage account (plus a KMS grant) and restore it. It's higher
fidelity but heavier (cross-account snapshot + KMS sharing) and would sit outside
Terraform's management of `module.rds`, so the logical `pg_dump` copy above is
preferred for a "just a copy for now" seed.
