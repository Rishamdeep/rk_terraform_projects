# Creates S3 bucket
resource "aws_s3_bucket" "pipeline-bucket" {
  bucket = var.bucket_name
}

# Creates a code pipeline
resource "aws_codepipeline" "DockerPipelineTF" {
  name = "DockerPipelineTF"
  role_arn = aws_iam_role.pipeline_role.arn
  artifact_store {
    location = aws_s3_bucket.pipeline-bucket.bucket
    type = "S3"
  }
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        BranchName = "main", 
        PollForSourceChanges = "false",
        RepositoryName = var.repository_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      configuration = {
      ProjectName = aws_codebuild_project.DockerBuildTF.id

    }
    }
  }
}