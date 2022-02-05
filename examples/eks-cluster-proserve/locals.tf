locals {
  eks_cluster = {
    map_roles = concat(var.eks_cluster.map_roles, [
      {
        rolearn  = data.aws_caller_identity.current.arn
        username = "codebuild"
        groups   = ["system:masters"]
      }
    ])
    compute = {
      nodegroups = {
        aws_managed = var.eks_cluster.compute.nodegroups.aws_managed
        self_managed = var.eks_cluster.compute.nodegroups.self_managed
      } 
      fargate_profiles = var.eks_cluster.compute.fargate_profiles
    }
  }
}
