codebuild_project_ec2_vpc_id = "vpc-0903b9000fca796da"
codebuild_project_list_ec2_subnet_id = [
  "subnet-058c6d2c63ef6dbd7",
  "subnet-029d9418d5be4ad2b",
  "subnet-0f4fdef51814b866a"
]
codepipeline_include_test_stage = true
codepipeline_include_destroy_stage = false
codepipeline_source_buildspec_path = "deploy/ci_cd/codepipeline/buildspec"
codepipeline_source_type = "S3"
codepipeline_source_repo_path = "aws-samples/aws-eks-accelerator-for-terraform"
codepipeline_source_repo_branch_name = "master"
codepipeline_source_terraform_path = "examples/eks-cluster-basic-via-codepipeline"
codepipeline_source_terraform_variable_path = "examples/eks-cluster-basic-via-codepipeline/__variables/variables.tfvars"
environment = "sample"