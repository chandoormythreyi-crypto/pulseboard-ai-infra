locals {
  env_slug = "prod" # module env validation accepts dev|staging|prod
  azs      = ["us-east-1a", "us-east-1b"]
  tags     = {}

  public_subnet_cidrs      = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i) }
  private_app_subnet_cidrs = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i + 10) }
  private_rds_subnet_cidrs = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i + 20) }
}

module "vpc" {
  source = "../../modules/aws_vpc"

  vpc_cidr                 = var.vpc_cidr
  availability_zones       = local.azs
  public_subnet_cidrs      = local.public_subnet_cidrs
  private_app_subnet_cidrs = local.private_app_subnet_cidrs
  private_rds_subnet_cidrs = local.private_rds_subnet_cidrs
  env                      = local.env_slug
  tags                     = local.tags
}

resource "aws_db_subnet_group" "rds" {
  name       = "${local.project}-${local.environment}-rds"
  subnet_ids = [for s in module.vpc.private_rds_subnet_ids : s.id]
  tags       = local.tags
}

module "rds_sg" {
  source = "../../modules/aws_security_group"

  name   = "${local.project}-${local.environment}-rds"
  vpc_id = module.vpc.vpc_id

  ingress_rules = [{
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "PostgreSQL from within the VPC (app subnets)"
  }]

  egress_rules = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All egress"
  }]

  env  = local.env_slug
  tags = local.tags
}
