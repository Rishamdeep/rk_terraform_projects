# Creates an ecr repository
resource "aws_ecr_repository" "pipeline-repo" {
  name = var.ecr_repository_name
}


