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

eks_compute = {
  nodegroups = {
    aws_managed  = {
        # example for a managed eks nodegroup (3AZ - 3 x m5.large) 
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
  fargate_profiles = {
      # required for when compute is fully serverless (allows "core" services to run)
    kubesystem = {
      fargate_profile_name = "kube-system"
      fargate_profile_namespaces = [{
        namespace = "kube-system"
        k8s_labels = {}
      }]
      subnet_ids = [
        "subnet-058c6d2c63ef6dbd7",
        "subnet-029d9418d5be4ad2b",
        "subnet-0f4fdef51814b866a"
      ]
    }
      # example of a fargate profile
    profile1 = {
      additional_tags = {}
      fargate_profile_name = "profile1"
      fargate_profile_namespaces = [{
        namespace = "profile1"
        k8s_labels = {
          Environment = "preprod"
          Zone        = "dev"
          env         = "fargate"
        }
      }]
      subnet_ids = [
        "subnet-058c6d2c63ef6dbd7",
        "subnet-029d9418d5be4ad2b",
        "subnet-0f4fdef51814b866a"
      ]
    }
  }
}

eks_addons = {
  amazon_eks_aws_ebs_csi_driver = {
    enable = false
  }
  amazon_eks_vpc_cni = {
    enable = true
  }
  amazon_eks_coredns = {
    enable = true
  }
  amazon_eks_kube_proxy = {
    enable = true
  }
  argocd = {
    enable = true,
    applications = {
      addons = {
        add_on_application  = true
          # the below is a secretsmanager:secret reference for accessing private repositories 
        # admin_password_secret_name = "password"
        path                = "chart"
        repo_url            = "https://github.com/aws-samples/eks-blueprints-add-ons.git"  
      }
    }
    argocd_manage_add_ons = true
  }
  aws_cloudwatch_metrics = {
    enable = true
  }
  aws_efs_csi_driver = {
    enable = false
  }
  aws_load_balancer_controller = {
    enable = true
  }
  cluster_autoscaler = {
    enable = false
  }
  metrics_server = {
    enable = true
  }
}

eks_teams = {
  team1 = {
    compute_quota = {
      "requests.cpu" = "1000m",
      "requests.memory" = "4Gi",
      "limits.cpu" = "2000m",
      "limits.memory" = "8Gi"
    }
    labels = {
      bsbcc = "example",
      appname = "example",
      testingNewLabel = "blah"
    }
    network_policies = {
      policy1 = {
        ingress = [{}]
        egress = [{}]
        pod_selector = [{}]
        policy_types = ["Ingress"]
      },
      policy2 = {
        ingress = [{}]
        egress = [{}]
        pod_selector = [{}]
        policy_types = ["Egress"]
      }
    }
    object_quota = { 
      pods = "10",
      secrets = "10",
      services = "10"
    }
  }
  team2 = {
    compute_quota = {
      "requests.cpu" = "1000m",
      "requests.memory" = "4Gi",
      "limits.cpu" = "2000m",
      "limits.memory" = "8Gi"
    }
    labels = {
      bsbcc = "example",
      appname = "example",
      testingNewLabel = "blah2"
    }
    network_policies = {
      policy1 = {
        ingress = [{
          from = [{
            namespace_selector = [{
              match_labels = {
                "team" = "operations"
              }
            }]
          }]
        }]
        egress = [{}]
        pod_selector = [{}]
        policy_types = ["Ingress"]
      }
      policy2 = {
        ingress = [{}]
        egress = [{}]
        pod_selector = [{}]
        policy_types = ["Egress"]
      }
      policy3 = {
        ingress = [{}]
        egress = [{}]
        pod_selector = [{}]
        policy_types = ["Egress"]
      }
    }
    object_quota = { 
      pods = "10",
      secrets = "10",
      services = "10"
    }
  }
}

general = {
  region = "ap-southeast-2"
  tags = {
    testing-tag-1 = "first"
  },
  zone = "dev"
}