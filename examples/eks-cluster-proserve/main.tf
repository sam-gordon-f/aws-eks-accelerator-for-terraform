module "aws-eks-accelerator-for-terraform" {
  source = "github.com/aws-samples/aws-eks-accelerator-for-terraform"

  create_eks          = true
  kubernetes_version  = var.eks_cluster.kubernetes.version
  managed_node_groups = local.eks_cluster.compute.nodegroups.aws_managed
  map_roles           = local.eks_cluster.map_roles
  private_subnet_ids  = var.eks_cluster.vpc.subnets
  vpc_id              = var.eks_cluster.vpc.id
}

module "aws-eks-accelerator-for-terraform-modules" {
  source = "github.com/aws-samples/aws-eks-accelerator-for-terraform/modules/kubernetes-addons"

  eks_cluster_id        = module.aws-eks-accelerator-for-terraform.eks_cluster_id
  enable_karpenter      = true
  enable_metrics_server = true

  depends_on = [
    module.aws-eks-accelerator-for-terraform.self_managed_node_groups
  ]
}
