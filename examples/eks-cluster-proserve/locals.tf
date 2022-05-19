locals {
  eks_cluster = {
    map_roles = concat(var.eks_cluster.map_roles, [
      {
        rolearn  = data.aws_iam_session_context.current.issuer_arn
        username = "ci-cd"
        groups   = ["system:masters"]
      }
    ])
    compute = {
      nodegroups = {
        aws_managed = var.eks_compute.nodegroups.aws_managed
        self_managed = var.eks_compute.nodegroups.self_managed
      } 
      fargate_profiles = var.eks_compute.fargate_profiles
    }
  }
}
