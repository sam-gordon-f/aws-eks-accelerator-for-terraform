####
# a. Create core eks-cluster / nodes 
####

module "eks_cluster" {
  source = "github.com/aws-ia/aws-eks-accelerator-for-terraform?ref=v4.0.2"

  cluster_endpoint_private_access         = var.eks_cluster.cluster_endpoint_private_access
  cluster_endpoint_public_access          = var.eks_cluster.cluster_endpoint_public_access
  cluster_security_group_additional_rules = var.eks_cluster.cluster_security_group_additional_rules
  cluster_version                         = var.eks_cluster.cluster_version
  create_eks                              = true
  # combination of what the customer provides and what the proserve wrapper adds
  fargate_profiles                        = local.eks_cluster.compute.fargate_profiles
  # combination of what the customer provides and what the proserve wrapper adds
  managed_node_groups                     = local.eks_cluster.compute.nodegroups.aws_managed
  # combination of what the customer provides and what the proserve wrapper adds
  map_roles                               = local.eks_cluster.map_roles
  private_subnet_ids                      = var.eks_cluster.vpc.subnets
  vpc_id                                  = var.eks_cluster.vpc.id
  zone                                    = var.general.zone
}

####
# b. deploy all non-gitops style applications to the cluster
####

module "eks_cluster_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.2"

  eks_cluster_id                        = module.eks_cluster.eks_cluster_id

  # vpc-cni - allows for assigning private IP addresses to pods
  # https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html
  enable_amazon_eks_vpc_cni             = true
  
  # core-dns - deploys a dns server to serve your cluster
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
  enable_amazon_eks_coredns             = true
  
  # kube-proxy - maintains network rules on ec2 instances
  # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  enable_amazon_eks_kube_proxy          = true
  
  # ebs-csi-driver - provides an interface for container orchestrators to interact with ebs
  # https://github.com/kubernetes-sigs/aws-ebs-csi-driver
  enable_amazon_eks_aws_ebs_csi_driver  = true

  # argocd - manages service deployments from git
  # https://github.com/argoproj/argo-cd
  enable_argocd                         = true
  argocd_manage_add_ons                 = true
  argocd_applications                   = var.eks_addons.argocd.applications
  
  # aws load balancer controller - addon for allowing eks cluster to manage aws alb/nlbs
  # https://github.com/kubernetes-sigs/aws-load-balancer-controller
  enable_aws_load_balancer_controller   = true

  # cluster autoscaler - automatically adjusts the size of the Kubernetes cluster
  # https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
  # enable_cluster_autoscaler             = true

  # cluster metrics server - scalable, efficient source of container resource metrics for Kubernetes 
  # https://github.com/kubernetes-sigs/metrics-server
  enable_metrics_server                 = true
  
  depends_on = [
    module.eks_cluster.managed_node_groups
  ]
}

####
# c. deploy "teams" who will be operating the cluster
####

module "eks_cluster_teams" {
  source = "./modules/eks-teams"

  eks_teams = var.eks_teams

  depends_on = [
    module.eks_cluster
  ]
}