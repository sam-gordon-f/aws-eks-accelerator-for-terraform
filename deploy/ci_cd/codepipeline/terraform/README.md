## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.post-codepipeline-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.destroy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.test_checkov](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.test_conftest](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.test_terrascan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.test_tflint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codebuild_project.test_tfsec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_codecommit_repository.source_cluster_codecommit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codecommit_repository) | resource |
| [aws_codepipeline.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline) | resource |
| [aws_codepipeline_webhook.codepipeline_webhook_github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codepipeline_webhook) | resource |
| [aws_codestarconnections_connection.source_cluster_bitbucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_codestarconnections_connection.source_cluster_github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_codestarconnections_connection.source_cluster_github_enterprise_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codestarconnections_connection) | resource |
| [aws_iam_role.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codepipeline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.post-codepipeline-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.post-codepipeline-lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_s3_bucket.artefacts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.source_cluster_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.tf_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.tf_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_security_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [archive_file.post-codepipeline-lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild"></a> [codebuild](#input\_codebuild) | n/a | <pre>object({<br>    vpc_id     = string<br>    subnet_ids = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_codepipeline"></a> [codepipeline](#input\_codepipeline) | n/a | <pre>object({<br>    source = object({<br>      type = string<br>      repo = object({<br>        project = string<br>        name    = string<br>        branch  = string<br>      })<br>    })<br>    include_destroy_stage = bool,<br>    include_lambda_stage  = bool,<br>    include_test_stage    = bool<br>  })</pre> | <pre>{<br>  "include_destroy_stage": false,<br>  "include_lambda_stage": true,<br>  "include_test_stage": true,<br>  "source": {<br>    "repo": {<br>      "branch": "master",<br>      "name": "aws-eks-accelerator-for-terraform",<br>      "project": "aws-samples"<br>    },<br>    "type": "GitHub"<br>  }<br>}</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Defines labels for your terraform resources to help discover/differentiate | `string` | n/a | yes |
| <a name="input_github"></a> [github](#input\_github) | n/a | <pre>object({<br>    token          = string,<br>    webhook_secret = string<br>  })</pre> | <pre>{<br>  "token": "changeme",<br>  "webhook_secret": "changeme"<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags for each resource required by the codepipeling solution | `map(string)` | `{}` | no |
| <a name="input_terraform"></a> [terraform](#input\_terraform) | n/a | <pre>object({<br>    project_path  = string,<br>    variable_path = string,<br>    deploy_role = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
