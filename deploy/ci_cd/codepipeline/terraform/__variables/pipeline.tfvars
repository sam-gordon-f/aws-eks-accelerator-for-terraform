codebuild = {
  vpc_id = "vpc-0903b9000fca796da",
  subnet_ids = [
    "subnet-058c6d2c63ef6dbd7",
    "subnet-029d9418d5be4ad2b",
    "subnet-0f4fdef51814b866a"
  ]
}
codepipeline = {
  source = {
    type = "S3"
    repo = {
      branch  = "master",
      project = "",
      name    = "accelerator-test"
    }
  },
  include_destroy_stage = false
  include_lambda_stage = true
  include_test_stage    = true
}
environment = "sample"
region = "ap-southeast-2"
terraform = {
  project_path  = "examples/eks-cluster-proserve",
  variable_path = "examples/eks-cluster-proserve/__variables/variables.tfvars"
  deploy_role = "arn:aws:iam::509164722760:role/tmp-tf-deploy"
}