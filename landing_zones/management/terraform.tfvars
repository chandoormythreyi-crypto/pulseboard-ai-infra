account_emails = {
  tooling  = "csongor+pulseboardtooling@apexlab.io"
  security = "csongor+pulseboardsecurity@apexlab.io"
  stage    = "csongor+pulseboardstage@apexlab.io"
  prod     = "csongor+pulseboardprod@apexlab.io"
}

admin_user = {
  given_name = "Csongor"
  last_name  = "Vargha"
  username   = "csongor"
  email      = "csongor.vargha+pulseboard@apexlab.io"
}

# false: adopt the Identity Center user created by hand in the console.
# true:  let terraform create and own the user record.
manage_admin_user = false

billing_alert_email    = "csongor+pulseboardbilling@apexlab.io"
org_monthly_budget_usd = 500

allowed_regions = ["us-east-1"]

allowed_github_repositories = [
  "chandoormythreyi-crypto/pulseboard-ai-be:*",
  "chandoormythreyi-crypto/pulseboard-ai-fe:*",
  "chandoormythreyi-crypto/pulseboard-marketing:*",
]
