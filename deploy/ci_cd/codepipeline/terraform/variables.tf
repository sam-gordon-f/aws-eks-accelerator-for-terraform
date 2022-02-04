variable "environment" {
  type = string
  description = "Defines labels for your terraform resources to help discover/differentiate"
}

variable "tags" {
  type = map(string)
  default = {}
  description = "Tags for each resource required by the codepipeling solution"
}

####
# codepipeline/build required variables
####

variable "codepipeline" {
  type = object({
    source = object({
      type = string
      repo = object({
        project = string
        name = string
        branch = string
      })
    })
    include_test_stage = bool,
    include_destroy_stage = bool
  })
  default = {
    source = {
      type = "GitHub",
      repo = {
        project = "aws-samples"
        name = "aws-eks-accelerator-for-terraform"
        branch = "master"
      }
    },
    include_test_stage = true,
    include_destroy_stage = false
  }
}

variable "codebuild" {
  type = object({
    vpc_id = string
    subnet_ids = list(string)
  })
}

variable "terraform" {
  type = object({
    project_path = string,
    variable_path = string
  })
}

variable "github" {
  type = object({
    token = string,
    webhook_secret = string
  })
  default = {
    token = "changeme"
    webhook_secret = "changeme"
  }
}