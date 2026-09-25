# Route53 hosted zone for pulseboard.world. The domain registration itself is
# NOT moved to Route53 — only DNS is. Delegate by pointing the registrar's
# nameservers at this zone's name servers (see the route53_name_servers output).
# Until delegation is live, ACM validation cannot complete on apply.
resource "aws_route53_zone" "world" {
  name    = "pulseboard.world"
  comment = "PulseBoard DNS (managed by Terraform; registration stays at the registrar)"
  tags    = local.tags
}

# Records mirrored from the Cloudflare zone ahead of the NS cutover. The
# frontend (staging) alias + ACM validation records are managed by
# module.frontend_cdn. The ALB lives in the management account, so CNAME it.
locals {
  cname_records = {
    "api"         = "pulseboard-world-alb-17260886.us-east-1.elb.amazonaws.com" # production API
    "api-staging" = "pulseboard-world-alb-17260886.us-east-1.elb.amazonaws.com"
  }
}

resource "aws_route53_record" "cname" {
  for_each = local.cname_records

  zone_id = aws_route53_zone.world.zone_id
  name    = "${each.key}.pulseboard.world"
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}

# Remaining records copied from the Cloudflare export (backups/cloudflare/pulseboard.world-2026-09-25.*).
# - *._domainkey: SES DKIM (email signing)
# - _<hash>.*: ACM validation for the existing management-account certs (keeps renewal working)
# - pay, _domainconnect: GoDaddy
locals {
  extra_cname_records = {
    "2shhgjhbdngfzteeislz6466nfioiivr._domainkey"   = "2shhgjhbdngfzteeislz6466nfioiivr.dkim.amazonses.com"
    "_1bcc68e9a580bb72edd44a4a842ca41c"             = "_87c57370de8f0541dea1bd6fc628928e.jkddzztszm.acm-validations.aws"
    "_60058ab187a273f96a755e875550b08e.api"         = "_b007a678b8e1fc8af20e0e0e4281d2af.jkddzztszm.acm-validations.aws"
    "_74c32f3d4238934b4430f3b0877ae2e8.staging"     = "_a6daeedff91c7eaf6cb6e917f4cfb39f.jkddzztszm.acm-validations.aws"
    "_cadabb5bea46cdfb0425dcccb91d8cc1.api-staging" = "_3778227a9cddd8e35e8c74fa73580097.jkddzztszm.acm-validations.aws"
    "_domainconnect"                                = "_domainconnect.gd.domaincontrol.com"
    "dnbgrmldn52b72vwncrmz6zftatminrx._domainkey"   = "dnbgrmldn52b72vwncrmz6zftatminrx.dkim.amazonses.com"
    "pay"                                           = "paylinks.commerce.godaddy.com"
    "vdyhppeh5c4eehnucwi36jxpgufai3xr._domainkey"   = "vdyhppeh5c4eehnucwi36jxpgufai3xr.dkim.amazonses.com"
  }

  txt_records = {
    "_dmarc" = "v=DMARC1; p=quarantine; adkim=r; aspf=r; rua=mailto:dmarc_rua@onsecureserver.net;"
  }
}

resource "aws_route53_record" "extra_cname" {
  for_each = local.extra_cname_records

  zone_id = aws_route53_zone.world.zone_id
  name    = "${each.key}.pulseboard.world"
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}

resource "aws_route53_record" "txt" {
  for_each = local.txt_records

  zone_id = aws_route53_zone.world.zone_id
  name    = "${each.key}.pulseboard.world"
  type    = "TXT"
  ttl     = 300
  records = [each.value]
}

# dev.pulseboard.world — the stage account's frontend host until customers sign
# off on moving staging. pulseboard.world stays on Cloudflare for now, so dev is
# delegated there via NS records (see dev_name_servers output); the delegation is
# also mirrored into the prepared pulseboard.world zone for the later cutover.
resource "aws_route53_zone" "dev" {
  name    = "dev.pulseboard.world"
  comment = "Stage-account frontend (delegated from pulseboard.world)"
  tags    = local.tags
}

resource "aws_route53_record" "dev_delegation" {
  zone_id = aws_route53_zone.world.zone_id
  name    = "dev.pulseboard.world"
  type    = "NS"
  ttl     = 300
  records = aws_route53_zone.dev.name_servers
}

# Customer-facing staging stays on the management-account CloudFront until the
# switch is confirmed; keeps it resolving if pulseboard.world is delegated first.
resource "aws_route53_record" "staging" {
  zone_id = aws_route53_zone.world.zone_id
  name    = "staging.pulseboard.world"
  type    = "CNAME"
  ttl     = 300
  records = ["ddrd3vmseqa8i.cloudfront.net"]
}
