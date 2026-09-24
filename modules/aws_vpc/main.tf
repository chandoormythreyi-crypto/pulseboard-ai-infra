resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.env}-igw" })
}

resource "aws_subnet" "public_sn" {
  for_each = var.public_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.env}-public-sn-${each.key}"
    }
  )
}

resource "aws_subnet" "rds_private" {
  for_each = var.private_rds_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.tags, { Name = "${var.env}-rds-private-sn-${each.key}" })
}

resource "aws_subnet" "private" {
  for_each = var.private_app_subnet_cidrs

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.tags, { Name = "${var.env}-app-private-sn-${each.key}" })
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.env}-nat-eip" })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public_sn)[0].id

  tags = merge(var.tags, { Name = "${var.env}-nat-gw" })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.env}-public-rt" })
}

resource "aws_route" "public_internet_gateway_route" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each = aws_subnet.public_sn

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, { Name = "${var.env}-private-rt" })
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id         = aws_route_table.private_rt.id
  nat_gateway_id         = aws_nat_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_rds_rt_assoc" {
  for_each = aws_subnet.rds_private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_app_rt_assoc" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
