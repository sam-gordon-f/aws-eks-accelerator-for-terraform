variable "region" {
  type = string
}

variable "eks_cluster" {
  type = object({
    compute = object({
      nodegroups = object({
        aws_managed  = any
        self_managed = any
      })
      fargate_profiles = any
    })
    kubernetes = object({
      version = string
    })
    map_roles = any
    name      = string
    vpc = object({
      id      = string
      subnets = list(string)
    })
  })
}

variable "eks_addons" {
  type = any
}