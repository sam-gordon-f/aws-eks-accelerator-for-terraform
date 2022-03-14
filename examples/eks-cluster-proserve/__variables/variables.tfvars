eks_cluster = {
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
  kubernetes = {
    version = "1.21"
  }
  map_roles = [
    {
      rolearn  = "arn:aws:iam::509164722760:role/AWSReservedSSO_AdministratorAccess_7b03154eac0dbfd9"
      username = "SSOAdminAccess"
      groups   = ["system:masters"]
    },
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
}

general = {
  zone = "dev"
}

region = "ap-southeast-2"

