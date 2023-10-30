# Creates iam role for codebuild
resource "aws_iam_role" "build_role" {
  name = "build_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy" "build_policy" {
  name = "build_policy"
  role = aws_iam_role.build_role.id
  policy = "${file("cb_iam_policy.json")}"
}