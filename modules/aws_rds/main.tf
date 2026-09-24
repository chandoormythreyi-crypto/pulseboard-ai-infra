data "aws_region" "current" {}

locals {
  connection_scheme = startswith(var.engine, "postgres") ? "postgresql" : (
    startswith(var.engine, "mysql") || startswith(var.engine, "aurora-mysql") ? "mysql" : "sqlserver"
  )
}

resource "aws_cloudwatch_log_group" "proxy_log_group" {
  count             = var.use_proxy ? 1 : 0
  name              = "/aws/rds/proxy/${var.instance_identifier}-proxy"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.env}-db-proxy-log-group" })
}

resource "aws_db_instance" "database" {
  identifier = var.instance_identifier

  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  iops                  = var.iops
  storage_encrypted     = true

  engine                     = var.engine
  engine_version             = var.engine_version
  multi_az                   = var.multi_az
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  db_name  = var.rds_db_name
  username = var.username
  password = coalesce(var.password, random_password.db_password.result)

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = var.security_group_ids

  final_snapshot_identifier = var.final_snapshot_identifier
  skip_final_snapshot       = var.skip_final_snapshot
  maintenance_window        = var.maintenance_window
  backup_window             = var.backup_window
  backup_retention_period   = var.backup_retention_period
  delete_automated_backups  = var.delete_automated_backups

  performance_insights_enabled    = true
  ca_cert_identifier              = var.ca_cert_identifier_name
  license_model                   = var.license_model
  deletion_protection             = var.deletion_protection
  apply_immediately               = var.apply_immediately
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval

  tags = merge(var.tags, { Name = "${var.env}-db-instance" })
}

resource "random_password" "db_password" {
  length  = 42
  special = false
}

resource "aws_secretsmanager_secret" "password" {
  name                    = var.instance_identifier
  recovery_window_in_days = 0

  tags = merge(var.tags, { Name = "${var.env}-db-password" })
}

resource "aws_secretsmanager_secret_version" "password" {
  secret_id = aws_secretsmanager_secret.password.id
  secret_string = jsonencode({
    "username"             = aws_db_instance.database.username
    "password"             = aws_db_instance.database.password
    "engine"               = aws_db_instance.database.engine
    "host"                 = aws_db_instance.database.address
    "port"                 = aws_db_instance.database.port
    "dbInstanceIdentifier" = aws_db_instance.database.identifier
  })
}

resource "aws_secretsmanager_secret" "connection_string" {
  name                    = "${var.instance_identifier}-rds-connection-string"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Name = "${var.env}-db-connection-string" })
}

resource "aws_secretsmanager_secret_version" "connection_string" {
  secret_id = aws_secretsmanager_secret.connection_string.id
  secret_string = "${local.connection_scheme}://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${
    var.use_proxy ? aws_db_proxy.proxy[0].endpoint : aws_db_instance.database.endpoint
  }/${aws_db_instance.database.db_name}"
  version_stages = ["AWSCURRENT"]
}



resource "random_id" "snapshot_suffix" {
  byte_length = 4
}

resource "aws_db_instance" "database_replica" {
  count          = var.replica == null ? 0 : 1
  identifier     = var.replica.name
  instance_class = var.replica.instance_class

  # Instead of replicate_source_db, create independent instance
  allocated_storage = aws_db_instance.database.allocated_storage
  engine            = aws_db_instance.database.engine
  engine_version    = aws_db_instance.database.engine_version
  license_model     = aws_db_instance.database.license_model

  # Use same credentials as source
  username = aws_db_instance.database.username
  password = aws_db_instance.database.password
  db_name  = aws_db_instance.database.db_name

  max_allocated_storage      = var.replica.max_allocated_storage
  storage_type               = var.replica.storage_type
  iops                       = var.replica.iops
  storage_encrypted          = true
  multi_az                   = false
  auto_minor_version_upgrade = false

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = var.security_group_ids

  final_snapshot_identifier = "${var.instance_identifier}-replica-final-snapshot-${random_id.snapshot_suffix.hex}"
  skip_final_snapshot       = var.skip_final_snapshot

  maintenance_window = var.maintenance_window

  performance_insights_enabled = true
  ca_cert_identifier           = var.ca_cert_identifier_name

  tags = merge(var.tags, { Name = "${var.env}-db-instance-replica" })
}

# Keep the same secrets management structure
resource "aws_secretsmanager_secret" "replica_connection_string" {
  count                   = var.replica == null ? 0 : 1
  name                    = "${var.replica.name}-rds-connection-string"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Name = "${var.env}-db-connection-string-replica" })
}

resource "aws_secretsmanager_secret_version" "replica_connection_string" {
  count         = var.replica == null ? 0 : 1
  secret_id     = aws_secretsmanager_secret.replica_connection_string[0].id
  secret_string = "${local.connection_scheme}://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database_replica[0].endpoint}/${aws_db_instance.database.db_name}"
}

resource "aws_db_proxy" "proxy" {
  count                  = var.use_proxy ? 1 : 0
  name                   = "${var.instance_identifier}-proxy"
  debug_logging          = false
  engine_family          = local.connection_scheme == "postgresql" ? "POSTGRESQL" : (local.connection_scheme == "mysql" ? "MYSQL" : "SQLSERVER")
  idle_client_timeout    = 1800
  require_tls            = false
  role_arn               = aws_iam_role.proxy_role[0].arn
  vpc_security_group_ids = var.security_group_ids
  vpc_subnet_ids         = var.subnet_ids

  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.password.arn
  }

  tags = merge(var.tags, { Name = "${var.env}-db-proxy" })

  depends_on = [aws_cloudwatch_log_group.proxy_log_group]
}

resource "aws_db_proxy_default_target_group" "proxy" {
  count         = var.use_proxy ? 1 : 0
  db_proxy_name = aws_db_proxy.proxy[0].name
}

resource "aws_db_proxy_target" "proxy" {
  count                  = var.use_proxy ? 1 : 0
  db_instance_identifier = aws_db_instance.database.identifier
  db_proxy_name          = aws_db_proxy.proxy[0].name
  target_group_name      = aws_db_proxy_default_target_group.proxy[0].name
}

resource "aws_iam_role" "proxy_role" {
  count = var.use_proxy ? 1 : 0
  name  = "${var.instance_identifier}-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = [
            "rds.amazonaws.com"
          ]
        },
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.env}-db-proxy-role" })
}

resource "aws_iam_policy" "proxy_secret_policy" {
  count       = var.use_proxy ? 1 : 0
  name        = "${var.instance_identifier}-proxy-secret-policy"
  description = "Policy for RDS proxy to get secrets."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "GetSecretValue"
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_secretsmanager_secret.password.arn}"
        ]
      },
      {
        Sid = "DecryptSecretValue"
        Action = [
          "kms:Decrypt"
        ],
        Effect = "Allow",
        Resource = [
          "${aws_secretsmanager_secret.password.arn}"
        ],
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current.region}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, { Name = "${var.env}-db-proxy-secret-policy" })
}

resource "aws_iam_role_policy_attachment" "proxy_role_attach" {
  count      = var.use_proxy ? 1 : 0
  role       = aws_iam_role.proxy_role[0].name
  policy_arn = aws_iam_policy.proxy_secret_policy[0].arn
}
