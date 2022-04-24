module "eks_cluster" {
  source = "github.com/aws-ia/aws-eks-accelerator-for-terraform?ref=v4.0.2"

  cluster_endpoint_private_access         = var.eks_cluster.cluster_endpoint_private_access
  cluster_endpoint_public_access          = var.eks_cluster.cluster_endpoint_public_access
  cluster_security_group_additional_rules = var.eks_cluster.cluster_security_group_additional_rules
  cluster_version                         = var.eks_cluster.cluster_version
  create_eks                              = true
  managed_node_groups                     = local.eks_cluster.compute.nodegroups.aws_managed
  map_roles                               = local.eks_cluster.map_roles
  private_subnet_ids                      = var.eks_cluster.vpc.subnets
  vpc_id                                  = var.eks_cluster.vpc.id
  zone                                    = var.general.zone
}

module "eks_cluster_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.2"

  eks_cluster_id                        = module.eks_cluster.eks_cluster_id

    ####
    # native supported
    #### 

  enable_amazon_eks_vpc_cni             = true
  enable_amazon_eks_coredns             = true
  enable_amazon_eks_kube_proxy          = true
  enable_amazon_eks_aws_ebs_csi_driver  = true

    ####
    # custom
    ####  

  # argocd - manages deployments from git
  # https://github.com/argoproj/argo-cd
  enable_argocd                         = true
  argocd_manage_add_ons                 = true
  argocd_applications                   = var.eks_addons.argocd.applications
  
  # aws load balancer controller - addon for allowing eks cluster to manage aws alb/nlbs
  # https://github.com/kubernetes-sigs/aws-load-balancer-controller
  enable_aws_load_balancer_controller   = true

  # cluster autoscaler - automatically adjusts the size of the Kubernetes cluster
  # https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
  enable_cluster_autoscaler             = true

  # cluster metrics server - scalable, efficient source of container resource metrics for Kubernetes 
  # https://github.com/kubernetes-sigs/metrics-server
  enable_metrics_server                 = true
  
  depends_on = [
    module.eks_cluster.managed_node_groups
  ]
}
