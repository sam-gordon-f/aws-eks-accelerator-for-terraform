variable "eks_cluster" {
  type = object({
    cluster_endpoint_private_access = bool
    cluster_endpoint_public_access = bool
    cluster_security_group_additional_rules = any
    cluster_version = string
    map_roles = any
    vpc = object({
      id      = string
      subnets = list(string)
    })
  })
}

variable "eks_compute" {
  type = any
}

variable "eks_addons" {
  type = any
}

variable "eks_teams" {
  type = any
}

variable "general" {
  type = object({
    region = string
    tags = map(string)
    zone = string
  })
}