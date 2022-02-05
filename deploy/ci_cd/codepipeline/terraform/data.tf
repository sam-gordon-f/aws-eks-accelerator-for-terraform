data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "archive_file" "post-codepipeline-lambda" {
  type        = "zip"
  source_dir  = "../lambda/post-codepipeline"
  output_path = "../lambda/post-codepipeline/deployment.zip"
}