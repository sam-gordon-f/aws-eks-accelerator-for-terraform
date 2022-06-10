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
    # merge of configuration provided and wrapper provided
  fargate_profiles                        = local.eks_cluster.compute.fargate_profiles
    # merge of configuration provided and wrapper provided
  managed_node_groups                     = local.eks_cluster.compute.nodegroups.aws_managed
    # merge of configuration provided and wrapper provided
  map_roles                               = local.eks_cluster.map_roles
  private_subnet_ids                      = var.eks_cluster.vpc.subnets
  tags                                    = var.general.tags
  vpc_id                                  = var.eks_cluster.vpc.id
  zone                                    = var.general.zone
}

####
# b. deploy all "non-gitops" applications to the cluster
# if argocd enabled - specify the repo in `var.argocd_applications`
####

module "eks_cluster_addons" {
  source = "github.com/aws-ia/terraform-aws-eks-blueprints//modules/kubernetes-addons?ref=v4.0.2"

  eks_cluster_id                        = module.eks_cluster.eks_cluster_id
  
    # aws-ebs-csi-driver - provides an interface for container orchestrators to interact with ebs
    # https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html
  enable_amazon_eks_aws_ebs_csi_driver             = var.eks_addons.amazon_eks_aws_ebs_csi_driver.enable

    # core-dns - deploys a dns server to serve your cluster
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
  enable_amazon_eks_coredns             = var.eks_addons.amazon_eks_coredns.enable
  
    # kube-proxy - maintains network rules on ec2 instances
    # https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html
  enable_amazon_eks_kube_proxy          = var.eks_addons.amazon_eks_kube_proxy.enable
  
    # vpc-cni - allows for assigning private IP addresses to pods
    # https://docs.aws.amazon.com/eks/latest/userguide/pod-networking.html
  enable_amazon_eks_vpc_cni             = var.eks_addons.amazon_eks_vpc_cni.enable

    # argocd - gitops style deployments from a specific git repo
    # https://github.com/argoproj/argo-cd
  enable_argocd                         = var.eks_addons.argocd.enable
  argocd_manage_add_ons                 = var.eks_addons.argocd.argocd_manage_add_ons
  argocd_applications                   = var.eks_addons.argocd.applications

    # aws-efs-csi-driver - provides an interface for container orchestrators to interact with efs
    # https://github.com/kubernetes-sigs/aws-efs-csi-driver
  enable_aws_efs_csi_driver             = var.eks_addons.aws_efs_csi_driver.enable

    # aws-clouwatch-metrics - collects, aggregates, and summarizes metrics and logs from your containerized applications and microservices
    # https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights.html
    # @TODO - not supported in current release version, need to update to be able to consume
  #enable_aws_cloudwatch_metrics             = var.eks_addons.enable_aws_cloudwatch_metrics.enable
  
    # aws load balancer controller - addon for allowing eks cluster to manage aws alb/nlbs
    # https://github.com/kubernetes-sigs/aws-load-balancer-controller
  enable_aws_load_balancer_controller   = var.eks_addons.aws_load_balancer_controller.enable

    # cluster autoscaler - automatically adjusts the size of the Kubernetes cluster
    # https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
  enable_cluster_autoscaler             = var.eks_addons.cluster_autoscaler.enable

    # cluster metrics server - scalable, efficient source of container resource metrics for Kubernetes 
    # https://github.com/kubernetes-sigs/metrics-server
  enable_metrics_server                 = var.eks_addons.metrics_server.enable
  
    # ensure that `addons` are added after cluster is available
  depends_on = [
    module.eks_cluster.managed_node_groups
  ]
}

####
# c. deploy "teams (or tenants)" who will be onboarded to the cluster
# for custom requirements, create a 'customer' specific module based off the module and reference in the wrapper
####

module "eks_cluster_teams" {
  source = "./modules/eks-teams"

    # merge the cluster id into the eks_cluster object
  eks_cluster = merge(var.eks_cluster, {
    eks_cluster_id = module.eks_cluster.eks_cluster_id
  })
  eks_teams        = var.eks_teams
  general          = var.general

    # ensure that `team` configurations are added after cluster and addons are available
  depends_on = [
    module.eks_cluster.managed_node_groups,
    module.eks_cluster_addons
  ]
}