module "rds" {
  source = "../../modules/aws_rds"

  instance_identifier = "${local.project}-${local.environment}"
  engine              = "postgres"
  engine_version      = var.db_engine_version
  instance_class      = var.db_instance_class
  license_model       = "postgresql-license"

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"

  rds_db_name = "pulseboard"
  username    = "pulseboard"
  # password omitted -> module generates one and stores it in Secrets Manager.

  subnet_group_name  = aws_db_subnet_group.rds.name
  subnet_ids         = toset([for s in module.vpc.private_rds_subnet_ids : s.id])
  security_group_ids = [module.rds_sg.id]

  multi_az                  = var.db_multi_az
  backup_retention_period   = var.db_backup_retention_period
  deletion_protection       = var.db_deletion_protection
  skip_final_snapshot       = var.db_skip_final_snapshot
  final_snapshot_identifier = "${local.project}-${local.environment}-final"

  # Plain single-instance Postgres: no read replica, no RDS Proxy.
  replica   = null
  use_proxy = false

  env  = local.env_slug
  tags = local.tags
}
