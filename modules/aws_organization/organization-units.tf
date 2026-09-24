resource "aws_organizations_organizational_unit" "root" {

  for_each = local.root_org_units

  name      = each.key
  parent_id = aws_organizations_organization.org.roots[0].id
}

resource "aws_organizations_organizational_unit" "level_1_units" {

  for_each = local.level_1_org_units

  name      = each.key
  parent_id = aws_organizations_organizational_unit.root[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_2_units" {

  for_each = local.level_2_org_units

  name      = each.key
  parent_id = aws_organizations_organizational_unit.level_1_units[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_3_units" {

  for_each = local.level_3_org_units

  name      = each.key
  parent_id = aws_organizations_organizational_unit.level_2_units[each.value.parent].id
}

resource "aws_organizations_organizational_unit" "level_4_units" {

  for_each = local.level_4_org_units

  name      = each.key
  parent_id = aws_organizations_organizational_unit.level_3_units[each.value.parent].id
}
