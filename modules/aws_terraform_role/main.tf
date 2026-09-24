data "aws_iam_policy_document" "terraform_role_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = var.terraform_role_allowed_assume_arns
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "terraform_role" {
  name = var.terraform_role_name

  assume_role_policy = data.aws_iam_policy_document.terraform_role_assume_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_policy_attachment" {
  role       = aws_iam_role.terraform_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
