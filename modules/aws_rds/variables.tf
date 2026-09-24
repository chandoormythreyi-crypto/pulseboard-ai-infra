variable "instance_identifier" {
  type = string
}
variable "instance_class" {
  type = string
}
variable "storage_type" {
  type    = string
  default = "gp2"
}
variable "max_allocated_storage" {
  type    = number
  default = 0
}
variable "allocated_storage" {
  type = number
}
variable "iops" {
  type    = number
  default = null
}
variable "engine" {
  type        = string
  description = "The engine to use for the database instance"
  default     = "sqlserver-se"
}
variable "engine_version" {
  type    = string
  default = "16.00.4185.3.v1"
}
variable "rds_db_name" {
  description = "The name of the database to create when the DB instance is created. If this parameter is not specified, no database is created."
  type        = string
  default     = null # Keep default as null, SQL server handles initial DB differently.
}
variable "username" {
  type    = string
  default = "roksh"
}
variable "env" {
  type = string
}
variable "security_group_ids" {
  type = list(string)
}
variable "use_proxy" {
  type    = bool
  default = false
}
variable "skip_final_snapshot" {
  type = bool
}
variable "replica" {
  type = object({
    name                  = string
    storage_type          = optional(string, "gp2")
    iops                  = optional(number)
    allocated_storage     = number
    max_allocated_storage = optional(number)
    instance_class        = string
    database_names        = list(string)
  })

  default = null
}
variable "maintenance_window" {
  type    = string
  default = "Sun:04:00-Sun:06:00"
}
variable "backup_window" {
  type    = string
  default = "00:00-03:59"
}
variable "backup_retention_period" {
  type = number
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
}

variable "ca_cert_identifier_name" {
  type    = string
  default = "rds-ca-rsa2048-g1"
}

variable "deletion_protection" {
  type = bool
}

variable "apply_immediately" {
  type    = bool
  default = false
}

variable "auto_minor_version_upgrade" {
  type    = bool
  default = false
}

variable "enabled_cloudwatch_logs_exports" {
  type    = set(string)
  default = []
}

variable "final_snapshot_identifier" {
  type = string
}

variable "password" {
  description = "Password for the master DB user. If null or empty, a random password will be generated."
  type        = string
  default     = null
  sensitive   = true
}

variable "subnet_ids" {
  type = set(string)
}
variable "subnet_group_name" {
  type = string
}
variable "monitoring_interval" {
  type    = number
  default = null
}
variable "delete_automated_backups" {
  type    = bool
  default = false
}
variable "multi_az" {
  type    = bool
  default = false
}
variable "license_model" {
  description = "License model for the database instance (e.g., 'license-included', 'bring-your-own-license'). Required for SQL Server."
  type        = string
  default     = "license-included"
}
