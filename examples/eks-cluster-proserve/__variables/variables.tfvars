eks_cluster = {
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true
  cluster_security_group_additional_rules = {
    vpc_ingress_access = {
      cidr_blocks = ["10.0.0.0/8"]
      description = "allow vpc to access cluster"
      protocol = "-1"
      from_port = "0"
      to_port = "65535"
      type = "ingress"
    }
  }
  cluster_version = "1.21"
  compute = {
    nodegroups = {
      aws_managed  = {
        mg_4 = {
          node_group_name = "managed-ondemand"
          instance_types  = ["m5.large"]
          subnet_ids      = [
            "subnet-058c6d2c63ef6dbd7",
            "subnet-029d9418d5be4ad2b",
            "subnet-0f4fdef51814b866a"
          ]
        }
      }
      self_managed = {}
    }
    fargate_profiles = {}
  }
  map_roles = [
      # allow Single sign on "administrators" the ability to interact with cluster
    {
      rolearn  = "arn:aws:iam::509164722760:role/AWSReservedSSO_AdministratorAccess_7b03154eac0dbfd9"
      username = "SSOAdminAccess"
      groups   = ["system:masters"]
    },
      # allow "EC2 SSM instances" the ability to interact with cluster
    {
      rolearn  = "arn:aws:iam::509164722760:role/EC2SSMInstance"
      username = "EC2SSMAccess"
      groups   = ["system:masters"]
    }
  ]
  vpc = {
    id = "vpc-0903b9000fca796da"
    subnets = [
      "subnet-058c6d2c63ef6dbd7",
      "subnet-029d9418d5be4ad2b",
      "subnet-0f4fdef51814b866a"
    ]
  }
}

eks_addons = {
  metrics_server = {
    enable = true
  }
  argocd = {
    enable = true,
    applications = {
      addons = {
        path                = "chart"
        repo_url            = "https://github.com/aws-samples/eks-blueprints-add-ons.git"
        add_on_application  = true
      }
    }
  }
}

general = {
  zone = "dev"
}

region = "ap-southeast-2"

