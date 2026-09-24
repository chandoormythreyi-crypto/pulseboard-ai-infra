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
