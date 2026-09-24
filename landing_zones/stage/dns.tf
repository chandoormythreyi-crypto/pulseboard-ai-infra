# Route53 hosted zone for pulseboard.world. The domain registration itself is
# NOT moved to Route53 — only DNS is. Delegate by pointing the registrar's
# nameservers at this zone's name servers (see the route53_name_servers output).
# Until delegation is live, ACM validation cannot complete on apply.
resource "aws_route53_zone" "world" {
  name    = "pulseboard.world"
  comment = "PulseBoard DNS (managed by Terraform; registration stays at the registrar)"
  tags    = local.tags
}
