locals {
    codepipeline_source_configuration_map = {
        "S3" = {
            name = "s3"
            provider         = "S3"
            configuration = {
                S3Bucket    = var.codepipeline_source_type == "S3" ? aws_s3_bucket.source_cluster_s3[0].id : null 
                S3ObjectKey = "deployment.zip" 
            }   
        },
        "CodeCommit" = {
            name = "codecommit"
            provider         = "CodeCommit"
            configuration = {
                RepositoryName = var.environment
                BranchName = var.codepipeline_source_repo_branch_name
            }
        },
        "GitHub" = {
            name = "github"
            provider         = "CodeStarSourceConnection"
            configuration = {
                ConnectionArn    = var.codepipeline_source_type == "GitHub" ? aws_codestarconnections_connection.source_cluster_github[0].id : null                 
                FullRepositoryId = var.codepipeline_source_repo_path
                BranchName       = var.codepipeline_source_repo_branch_name
            }
        },
        "GitHubEnterpriseServer" = {
            name = "github-enterprise"
            provider         = "CodeStarSourceConnection"
            configuration = {
                ConnectionArn    = var.codepipeline_source_type == "GitHubEnterpriseServer" ? aws_codestarconnections_connection.source_cluster_github_enterprise_server[0].id : null
                FullRepositoryId = var.codepipeline_source_repo_path
                BranchName       = var.codepipeline_source_repo_branch_name
            }
        },
       
        "Bitbucket" = {
            name = "bitbucket"
            provider         = "CodeStarSourceConnection"
            configuration = {
                ConnectionArn    = var.codepipeline_source_type == "Bitbucket" ? aws_codestarconnections_connection.source_cluster_bitbucket[0].id : null
                FullRepositoryId = var.codepipeline_source_repo_path
                BranchName       = var.codepipeline_source_repo_branch_name
            }
        }
    }
    codepipeline_source_configuration = lookup(local.codepipeline_source_configuration_map, var.codepipeline_source_type, {})
}