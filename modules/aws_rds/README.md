# RDS Module

This module creates a comprehensive Amazon RDS database infrastructure with advanced features including connection pooling, database replication, secrets management, and monitoring. It provides a production-ready database solution with SQL Server support, automated backups, and optional high availability configurations.

## Resources Created

- **RDS Database Instance**: Primary SQL Server database with configurable storage, compute, and performance settings
- **Secrets Manager**: Secure storage for database credentials and connection strings
- **RDS Proxy** (Optional): Connection pooling and management for improved performance and security
- **Database Replica** (Optional): Read replica for high availability
- **IAM Roles and Policies**: Service roles for RDS proxy operations

## Architecture

The module implements a multi-tier database architecture:
- **Primary Database**: Main SQL Server instance with encryption, backups, and monitoring
- **Connection Layer**: Optional RDS proxy for connection pooling and SSL termination
- **Replication Layer**: Optional replica database for data synchronization
- **Security Layer**: Secrets Manager integration with IAM-based access control

## Example for .tfvars

```hcl
env                 = "staging"
instance_identifier = "myapp-db-staging"
vpc_id              = "vpc-12345678"

# Database Configuration
instance_class      = "db.t3.medium"
allocated_storage   = 100
max_allocated_storage = 1000
storage_type        = "gp2"
engine              = "sqlserver-se"
engine_version      = "16.00.4185.3.v1"

# Authentication
username         = "dbadmin"
password         = null  # Will generate random password
rds_db_name      = "applicationdb"

# Network Configuration
subnet_group_name   = "db-subnet-group"
subnet_ids          = ["subnet-12345", "subnet-67890"]
security_group_ids  = ["sg-database"]

# Backup and Maintenance
backup_retention_period    = 7
backup_window             = "03:00-05:00"
maintenance_window        = "sun:05:00-sun:07:00"
final_snapshot_identifier = "myapp-db-staging-final-snapshot"
skip_final_snapshot       = false
deletion_protection       = true

# Optional Features
use_proxy = true
multi_az  = true

tags = {
  Environment = "staging"
  Project     = "myapp"
  Team        = "backend"
}
```

## Example for module with related resources
```hcl
locals {
  sql_server_ingress_app_runner_sgs = {
    for service_key in keys(local.app_runner_services) : service_key => module.app_runner_services[service_key].security_group_id
  }
}

module "weshop_sql_server" {
  source              = "../modules/rds"
  env                 = var.env
  instance_identifier = "${var.env}-${local.project_name}-sql-server"

  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.weshop_sql_server_sg.id]
  subnet_group_name  = aws_db_subnet_group.sql_server_subnet_group.name
  subnet_ids         = aws_db_subnet_group.sql_server_subnet_group.subnet_ids

  engine                    = var.database_engine
  instance_class            = var.database_instance_class
  storage_type              = "gp3"
  allocated_storage         = var.database_allocated_storage
  max_allocated_storage     = var.database_max_allocated_storage
  backup_retention_period   = 30
  deletion_protection       = var.env == "prod"
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.env}-${local.project_name}-sql-server-final-snapshot-${random_id.snapshot_suffix.hex}"
  multi_az                  = var.database_multi_az
  replica                   = var.database_replica
  tags                      = local.common_tags
}
```