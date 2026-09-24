# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_delegated_administrator

resource "aws_organizations_delegated_administrator" "delegation" {

  for_each = { for i in var.delegated_administrators : i.service_principal => i }

  account_id        = aws_organizations_account.accounts[each.value.account].id
  service_principal = each.value.service_principal
}
