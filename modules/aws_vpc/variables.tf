variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The vpc_cidr value must be a valid CIDR notation."
  }
}

variable "availability_zones" {
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "The availability zones to use for the VPC."
}

variable "public_subnet_cidrs" {
  type        = map(string)
  description = "A map of CIDR blocks for the public subnets where key is the availability zone."
  validation {
    condition     = alltrue([for cidr in values(var.public_subnet_cidrs) : can(cidrnetmask(cidr))])
    error_message = "All public_subnet_cidrs values must be valid CIDR notations."
  }
  validation {
    condition     = alltrue([for az in keys(var.public_subnet_cidrs) : can(contains(var.availability_zones, az))])
    error_message = "All public_subnet_cidrs keys must be valid availability zone names."
  }
}

variable "private_rds_subnet_cidrs" {
  type        = map(string)
  description = "A map of CIDR blocks for the private RDS subnets where key is the availability zone."
  validation {
    condition     = alltrue([for cidr in values(var.private_rds_subnet_cidrs) : can(cidrnetmask(cidr))])
    error_message = "All private_rds_subnet_cidrs values must be valid CIDR notations."
  }
  validation {
    condition     = alltrue([for az in keys(var.private_rds_subnet_cidrs) : can(contains(var.availability_zones, az))])
    error_message = "All private_rds_subnet_cidrs keys must be valid availability zone names."
  }
}
variable "private_app_subnet_cidrs" {
  type        = map(string)
  description = "A map of CIDR blocks for the private App subnets where key is the availability zone."
  validation {
    condition     = alltrue([for cidr in values(var.private_app_subnet_cidrs) : can(cidrnetmask(cidr))])
    error_message = "All private_app_subnet_cidrs values must be valid CIDR notations."
  }
  validation {
    condition     = alltrue([for az in keys(var.private_app_subnet_cidrs) : can(contains(var.availability_zones, az))])
    error_message = "All private_app_subnet_cidrs keys must be valid availability zone names."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resources."
}

variable "env" {
  type        = string
  description = "The environment (dev | staging | prod)."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "The env value must be one of: dev, staging, prod."
  }
}