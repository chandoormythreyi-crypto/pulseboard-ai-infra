locals {
  root_org_units = {
    for k, v in var.org_units : k => v if v.parent == null
  }

  level_1_org_units = {
    for k, v in var.org_units : k => v if lookup(local.root_org_units, v.parent != null ? v.parent : "", null) != null
  }

  level_2_org_units = {
    for k, v in var.org_units : k => v if lookup(local.level_1_org_units, v.parent != null ? v.parent : "", null) != null
  }

  level_3_org_units = {
    for k, v in var.org_units : k => v if lookup(local.level_2_org_units, v.parent != null ? v.parent : "", null) != null
  }

  level_4_org_units = {
    for k, v in var.org_units : k => v if lookup(local.level_3_org_units, v.parent != null ? v.parent : "", null) != null
  }

  merged_org_units = merge(
    aws_organizations_organizational_unit.root,
    aws_organizations_organizational_unit.level_1_units,
    aws_organizations_organizational_unit.level_2_units,
    aws_organizations_organizational_unit.level_3_units,
    aws_organizations_organizational_unit.level_4_units,
  )
}
