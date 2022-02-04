variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}

####
# codepipeline/build required variables
####

variable "codebuild_project_ec2_vpc_id" {
  type = string
}

variable "codebuild_project_list_ec2_subnet_id" {
  type = list(string)
}

variable "codepipeline_source_buildspec_path" {
  type = string
}

variable "codepipeline_source_terraform_path" {
  type = string
}

variable "codepipeline_source_terraform_variable_path" {
  type = string
  default = ""
}

variable "codepipeline_source_type" {
  type = string
  default = "S3"
  validation {    
    condition = var.codepipeline_source_type != "" && contains(["S3", "CodeCommit", "Bitbucket", "GitHub", "GitHubEnterpriseServer"], var.codepipeline_source_type)
    error_message = "The Codepipeline source must be one of [S3, CodeCommit, Bitbucket, GitHub, GitHubEnterpriseServer]."  
  }
}

variable "codepipeline_source_repo_path" {
  description = "format - 'project/repo'"
  default = "aws-samples/aws-eks-accelerator-for-terraform"
}

variable "codepipeline_source_repo_name" {
  default = "aws-eks-accelerator-for-terraform"
}

variable "codepipeline_source_repo_branch_name" {
  default = "master"
}

variable "codepipeline_include_destroy_stage" {
  type = bool
  default = false
}

variable "codepipeline_include_test_stage" {
  type = bool
  default = false
}

####
# github required variables
####

variable "github_webhook_secret" {
  default = "pleasechangeme"
}

variable "github_token" {
  default = "pleasechangeme"
}