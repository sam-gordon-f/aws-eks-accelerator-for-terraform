locals {
  codepipeline_source_configuration_map = {
    "S3" = {
      name     = "s3"
      provider = "S3"
      configuration = {
        S3Bucket    = var.codepipeline.source.type == "S3" ? aws_s3_bucket.source_cluster_s3[0].id : null
        S3ObjectKey = "deployment.zip"
      }
    },
    "CodeCommit" = {
      name     = "codecommit"
      provider = "CodeCommit"
      configuration = {
        RepositoryName = var.codepipeline.source.repo.name
        BranchName     = var.codepipeline.source.repo.branch
      }
    },
    "GitHub" = {
      name     = "github"
      provider = "CodeStarSourceConnection"
      configuration = {
        ConnectionArn    = var.codepipeline.source.type == "GitHub" ? aws_codestarconnections_connection.source_cluster_github[0].id : null
        FullRepositoryId = format("%s/%s", var.codepipeline.source.repo.project, var.codepipeline.source.repo.name)
        BranchName       = var.codepipeline.source.repo.branch
      }
    },
    "GitHubEnterpriseServer" = {
      name     = "github-enterprise"
      provider = "CodeStarSourceConnection"
      configuration = {
        ConnectionArn    = var.codepipeline.source.type == "GitHubEnterpriseServer" ? aws_codestarconnections_connection.source_cluster_github_enterprise_server[0].id : null
        FullRepositoryId = format("%s/%s", var.codepipeline.source.repo.project, var.codepipeline.source.repo.name)
        BranchName       = var.codepipeline.source.repo.branch
      }
    },

    "Bitbucket" = {
      name     = "bitbucket"
      provider = "CodeStarSourceConnection"
      configuration = {
        ConnectionArn    = var.codepipeline.source.type == "Bitbucket" ? aws_codestarconnections_connection.source_cluster_bitbucket[0].id : null
        FullRepositoryId = format("%s/%s", var.codepipeline.source.repo.project, var.codepipeline.source.repo.name)
        BranchName       = var.codepipeline.source.repo.branch
      }
    }
  }
  codepipeline_source_configuration = lookup(local.codepipeline_source_configuration_map, var.codepipeline.source.type, {})
}