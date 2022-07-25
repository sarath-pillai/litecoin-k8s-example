data "aws_caller_identity" "current" {}

resource "aws_iam_role" "role" {
  name = "${var.iam_identifier}-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          "AWS" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
    ]
  })

  tags = {
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.role.arn]
  }
}

resource "aws_iam_policy" "policy" {
  name   = "${var.iam_identifier}-${var.environment}"
  policy = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_group" "group" {
  name = "${var.iam_identifier}-${var.environment}"
}

resource "aws_iam_group_policy_attachment" "group-attachment" {
  group      = aws_iam_group.group.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_user" "user" {
  name = "${var.iam_identifier}-${var.environment}-user"
}

resource "aws_iam_group_membership" "group-membership" {
  name = "${var.iam_identifier}-${var.environment}-membership"

  users = [
    "${aws_iam_user.user.name}"
  ]

  group = aws_iam_group.group.name
}



