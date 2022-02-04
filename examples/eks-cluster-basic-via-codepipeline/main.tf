module "aws-eks-accelerator-for-terraform" {
  source = "github.com/aws-samples/aws-eks-accelerator-for-terraform"
  
  tenant            = local.tenant
  environment       = local.environment
  zone              = local.zone
  terraform_version = local.terraform_version

  # EKS Cluster VPC and Subnets
  vpc_id             = local.vpc_id
  private_subnet_ids = local.private_subnet_ids

  # EKS CONTROL PLANE VARIABLES
  create_eks         = true
  kubernetes_version = local.kubernetes_version

  # RBAC VARIABLES
  map_roles = local.map_roles

  # EKS MANAGED NODE GROUPS
  managed_node_groups = local.managed_node_groups
}

module "aws-eks-accelerator-for-terraform-modules" {
  source = "github.com/aws-samples/aws-eks-accelerator-for-terraform/modules/kubernetes-addons"

  eks_cluster_id = module.aws-eks-accelerator-for-terraform.eks_cluster_id
  enable_karpenter      = true
  enable_metrics_server = true

  depends_on = [
    module.aws-eks-accelerator-for-terraform.self_managed_node_groups
  ]
}
