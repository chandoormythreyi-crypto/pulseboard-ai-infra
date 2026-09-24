resource "aws_security_group" "security_group" {
  name   = var.name
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = "${var.env}-${var.name}" })
}

resource "aws_security_group_rule" "ingress" {
  for_each = {
    for rule in var.ingress_rules : "${rule.from_port}-${rule.to_port}-${rule.protocol}-${rule.self ? "self" : try(length(rule.cidr_blocks), 0) > 0 ? rule.cidr_blocks[0] : rule.description}" => rule
  }

  type        = "ingress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  description = each.value.description

  cidr_blocks              = each.value.self ? null : each.value.cidr_blocks
  source_security_group_id = each.value.self ? null : each.value.source_security_group_id
  self                     = each.value.self ? true : null

  security_group_id = aws_security_group.security_group.id
}

resource "aws_security_group_rule" "egress" {
  for_each = {
    for rule in var.egress_rules : "${rule.from_port}-${rule.to_port}-${rule.protocol}-${rule.self ? "self" : try(length(rule.cidr_blocks), 0) > 0 ? rule.cidr_blocks[0] : rule.description}" => rule
  }

  type        = "egress"
  from_port   = each.value.from_port
  to_port     = each.value.to_port
  protocol    = each.value.protocol
  description = each.value.description

  cidr_blocks              = each.value.self ? null : each.value.cidr_blocks
  source_security_group_id = each.value.self ? null : each.value.source_security_group_id
  self                     = each.value.self ? true : null

  security_group_id = aws_security_group.security_group.id
}

