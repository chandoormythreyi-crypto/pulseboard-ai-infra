# VPC Module

This module creates a complete VPC infrastructure with public and private subnets across multiple availability zones. It sets up the networking foundation for hosting applications and databases with proper isolation and internet connectivity.

## Resources Created

- **VPC**: Main virtual private cloud with DNS support and hostnames enabled
- **Internet Gateway**: Provides internet access for public subnets
- **Public Subnets**: Internet-facing subnets for load balancers, bastion hosts, etc.
- **Private App Subnets**: Application tier subnets with NAT gateway routing for outbound internet access
- **Private RDS Subnets**: Database tier subnets with no direct internet access
- **NAT Gateway**: Enables outbound internet access for private subnets
- **Elastic IP**: Static IP address for the NAT gateway
- **Route Tables**: Separate routing for public and private network traffic
- **Route Table Associations**: Links subnets to their appropriate route tables

## Architecture

The module implements a three-tier network architecture:
- **Public Tier**: Direct internet access via Internet Gateway
- **Application Tier**: Outbound internet access via NAT Gateway, no inbound public access
- **Database Tier**: No internet access, isolated for security

## Example for .tfvars

```hcl
env     = "staging"

vpc_cidr            = "10.17.0.0/16"
public_subnet_cidrs = { "eu-central-1a" = "10.17.0.0/24" }
private_rds_subnet_cidrs = {
  "eu-central-1a" = "10.17.12.0/24"
  "eu-central-1b" = "10.17.13.0/24"
}
private_app_subnet_cidrs = {
  "eu-central-1a" = "10.17.22.0/24"
  "eu-central-1b" = "10.17.23.0/24"
}

vpc_peering_connection_id = "111111111111111"
```
## Example for module

```hcl
module "vpc" {
  source = "../modules/vpc"

  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_rds_subnet_cidrs = var.private_rds_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs

  env     = var.env

  tags = local.common_tags
}
```