# Access Analyzer needs its service-linked role in the management (org) account
# before a delegated administrator can create an ORGANIZATION analyzer.
resource "aws_iam_service_linked_role" "access_analyzer" {
  aws_service_name = "access-analyzer.amazonaws.com"
}
