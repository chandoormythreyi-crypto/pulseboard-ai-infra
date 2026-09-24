# Organization-scoped IAM Access Analyzer — surfaces resources shared outside
# the organization. Requires the Organizations delegation set in the
# management LZ.
resource "aws_accessanalyzer_analyzer" "organization" {
  analyzer_name = "${local.project}-organization"
  type          = "ORGANIZATION"
}
