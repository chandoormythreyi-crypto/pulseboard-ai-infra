resource "aws_iam_role" "github" {
  name               = var.github_role_name
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
  tags               = var.tags
}

resource "aws_iam_policy" "assume_terraform_policy" {
  name   = "assume-terraform-role-policy"
  policy = data.aws_iam_policy_document.assume_terraform_role.json
}

resource "aws_iam_role_policy_attachment" "github_role_policy_attachment" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.assume_terraform_policy.arn
}

resource "aws_iam_policy" "terraform_state_access" {
  name = "terraform-state-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::infra-central-tf-state",
          "arn:aws:s3:::infra-central-tf-state/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_state_access" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.terraform_state_access.arn
}

resource "aws_iam_policy" "cloudformation_access" {
  name = "github-cloudformation-access-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudformation:GetResource",
          "cloudformation:ListResources",
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackResources"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "config:DescribeConformancePacks",
          "config:GetConformancePackComplianceDetails",
          "config:GetConformancePackComplianceSummary",
          "config:DescribeConfigurationRecorders",
          "config:DescribeDeliveryChannels"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudformation_access" {
  role       = aws_iam_role.github.name
  policy_arn = aws_iam_policy.cloudformation_access.arn
}
