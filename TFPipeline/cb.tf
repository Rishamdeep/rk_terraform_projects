
locals {
  buildspec_content = templatefile("${path.module}/buildspec_template.tftpl", {
    tag     = "0.0.0.1"
    region  = "us-east-1"
    ecr_url = "YOUR_AWS_ACCOUNT_NUMBER.dkr.ecr.us-east-1.amazonaws.com"
    ecr_repo = "your-ecr-repo"
  })
}

# Creates a code build
resource "aws_codebuild_project" "DockerBuildTF" {
  name = "DockerBuildTF"
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = var.image
    type = "LINUX_CONTAINER"
    privileged_mode = true
  }
  service_role = aws_iam_role.build_role.arn
  source {
    type = "CODEPIPELINE"
    buildspec = local.buildspec_content
  }
}
