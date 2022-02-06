## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.74.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws-eks-accelerator-for-terraform"></a> [aws-eks-accelerator-for-terraform](#module\_aws-eks-accelerator-for-terraform) | github.com/aws-samples/aws-eks-accelerator-for-terraform | n/a |
| <a name="module_aws-eks-accelerator-for-terraform-modules"></a> [aws-eks-accelerator-for-terraform-modules](#module\_aws-eks-accelerator-for-terraform-modules) | github.com/aws-samples/aws-eks-accelerator-for-terraform/modules/kubernetes-addons | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_addons"></a> [eks\_addons](#input\_eks\_addons) | n/a | `any` | n/a | yes |
| <a name="input_eks_cluster"></a> [eks\_cluster](#input\_eks\_cluster) | n/a | <pre>object({<br>    compute = object({<br>      nodegroups = object({<br>        aws_managed  = any<br>        self_managed = any<br>      })<br>      fargate_profiles = any<br>    })<br>    kubernetes = object({<br>      version = string<br>    })<br>    map_roles = any<br>    name      = string<br>    vpc = object({<br>      id      = string<br>      subnets = list(string)<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
