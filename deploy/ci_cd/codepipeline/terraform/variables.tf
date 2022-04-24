variable "codepipeline" {
  type = object({
    source = object({
      type = string
      repo = object({
        project = string
        name    = string
        branch  = string
      })
    })
    include_destroy_stage  = bool,
    include_lambda_stage   = bool,
    include_test_stage     = bool
  })
  default = {
    source = {
      type = "GitHub",
      repo = {
        project = "aws-samples"
        name    = "aws-eks-accelerator-for-terraform"
        branch  = "master"
      }
    },
    include_destroy_stage  = false,
    include_lambda_stage   = true,
    include_test_stage     = true
  }
}

variable "codebuild" {
  type = object({
    vpc_id     = string
    subnet_ids = list(string)
  })
}

variable "eks_cluster_name" {
  type = string
  description = "name of the eks-cluster being deployed. (Used for testing purposes)"
}

variable "environment" {
  type        = string
  description = "Defines labels for your terraform resources to help discover/differentiate"
}

variable "github" {
  type = object({
    token          = string,
    webhook_secret = string
  })
  default = {
    token          = "changeme"
    webhook_secret = "changeme"
  }
}

variable "project" {
  type = object({
    path  = string,
    variable_file = string,
    deploy_role = string
  })
  default = {
    path = "/examples/eks-cluster-proserve"
    variable_file = "/examples/eks-cluster-proserve/__variables/variables.tfvars",
    deploy_role = null,
  }
  description = "The only mandatory property is the 'path'"
}

variable "region" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags for each resource required by the codepipeling solution"
}