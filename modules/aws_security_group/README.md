# Security Group Module

This module creates AWS Security Groups with flexible ingress and egress rules for controlling network traffic. It provides a robust foundation for implementing network security policies with support for multiple rule types, validation, and standardized naming conventions.

## Resources Created

- **Security Group**: Main security group with configurable name and VPC association
- **Ingress Rules**: Inbound traffic rules with flexible source configurations (CIDR blocks, security groups, or self-referencing)
- **Egress Rules**: Outbound traffic rules with flexible destination configurations
- **Rule Validation**: Built-in validation to prevent conflicting rule configurations

## Architecture

The module implements a flexible rule-based security architecture:
- **Conditional Creation**: Optional security group creation based on requirements
- **Rule Flexibility**: Support for CIDR-based, security group-based, and self-referencing rules
- **Validation Logic**: Ensures proper rule configuration and prevents conflicts
- **Standardized Naming**: Consistent naming convention with environment and country prefixes

## Example for .tfvars

```hcl
env       = "staging"
name      = "web-server-sg"
vpc_id    = "vpc-12345678"

ingress_rules = [
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access from internet"
  },
  {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access from internet"
  },
  {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    source_security_group_id = "sg-app-servers"
    description              = "MySQL access from app servers"
  },
  {
    from_port   = 8080
    to_port     = 8090
    protocol    = "tcp"
    self        = true
    description = "Internal service communication"
  }
]

egress_rules = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
]

tags = {
  Environment = "staging"
  Project     = "web-application"
  Team        = "infrastructure"
  Purpose     = "web-server-security"
}
```

## Example for module

```hcl
module "weshop_sql_server_sg" {
  source = "../modules/security_group"
  name   = "${local.project_name}-sql-server-sg"
  vpc_id = module.vpc.vpc_id
  # Ingress rules with apply-time dependencies are moved to separate resources below.
  ingress_rules = []
  egress_rules = [
    {
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow outbound traffic to all"
    }
  ]

  env     = var.env
  tags    = local.common_tags
}
```