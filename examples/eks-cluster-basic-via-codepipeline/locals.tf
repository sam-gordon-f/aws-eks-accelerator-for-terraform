locals {
  tenant      = var.tenant
  environment = var.environment
  zone        = var.zone

  kubernetes_version = var.kubernetes_version
  terraform_version  = "Terraform v1.0.1"

  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  managed_node_groups = {
    mg_4 = {
      node_group_name = "managed-ondemand"
      instance_types  = ["m5.large"]
      subnet_ids      = local.private_subnet_ids
    }
  }
  map_roles = [
    {
      rolearn  = data.aws_caller_identity.current.arn
      username = "codebuild"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::899521659637:role/AWSReservedSSO_AdministratorAccess_a84023fba7a8e9ba"
      username = "SSOAdminAccess"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::899521659637:role/EC2SSMInstance"
      username = "EC2SSMAccess"
      groups   = ["system:masters"]
    }
  ]
}
