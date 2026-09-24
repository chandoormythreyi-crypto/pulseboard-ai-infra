data "aws_iam_policy_document" "assume_terraform_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    resources = var.terraform_roles_allowed_to_assume_arns

  }
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for repo in var.allowed_github_repositories : "repo:${repo}"]
    }
  }
}
