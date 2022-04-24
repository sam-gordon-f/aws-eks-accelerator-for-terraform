variable "eks_cluster" {
  type = object({
    cluster_endpoint_private_access = bool
    cluster_endpoint_public_access = bool
    cluster_security_group_additional_rules = any
    cluster_version = string
    compute = object({
      nodegroups = object({
        aws_managed  = any
        self_managed = any
      })
      fargate_profiles = any
    })
    map_roles = any
    vpc = object({
      id      = string
      subnets = list(string)
    })
  })
}

variable "eks_addons" {
  type = any
}

variable "general" {
  type = object({
    zone = string
  })
}

variable "region" {
  type = string
}