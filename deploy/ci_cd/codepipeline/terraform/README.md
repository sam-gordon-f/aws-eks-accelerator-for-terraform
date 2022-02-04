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
| [aws_security_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [archive_file.post-codepipeline-lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_codebuild_project_ec2_vpc_id"></a> [codebuild\_project\_ec2\_vpc\_id](#input\_codebuild\_project\_ec2\_vpc\_id) | n/a | `string` | n/a | yes |
| <a name="input_codebuild_project_list_ec2_subnet_id"></a> [codebuild\_project\_list\_ec2\_subnet\_id](#input\_codebuild\_project\_list\_ec2\_subnet\_id) | n/a | `list(string)` | n/a | yes |
| <a name="input_codepipeline_include_destroy_stage"></a> [codepipeline\_include\_destroy\_stage](#input\_codepipeline\_include\_destroy\_stage) | n/a | `bool` | `false` | no |
| <a name="input_codepipeline_include_test_stage"></a> [codepipeline\_include\_test\_stage](#input\_codepipeline\_include\_test\_stage) | n/a | `bool` | `false` | no |
| <a name="input_codepipeline_source_buildspec_path"></a> [codepipeline\_source\_buildspec\_path](#input\_codepipeline\_source\_buildspec\_path) | n/a | `string` | n/a | yes |
| <a name="input_codepipeline_source_repo_branch_name"></a> [codepipeline\_source\_repo\_branch\_name](#input\_codepipeline\_source\_repo\_branch\_name) | n/a | `string` | `"master"` | no |
| <a name="input_codepipeline_source_repo_name"></a> [codepipeline\_source\_repo\_name](#input\_codepipeline\_source\_repo\_name) | n/a | `string` | `"aws-eks-accelerator-for-terraform"` | no |
| <a name="input_codepipeline_source_repo_path"></a> [codepipeline\_source\_repo\_path](#input\_codepipeline\_source\_repo\_path) | format - 'project/repo' | `string` | `"aws-samples/aws-eks-accelerator-for-terraform"` | no |
| <a name="input_codepipeline_source_terraform_path"></a> [codepipeline\_source\_terraform\_path](#input\_codepipeline\_source\_terraform\_path) | n/a | `string` | n/a | yes |
| <a name="input_codepipeline_source_terraform_variable_path"></a> [codepipeline\_source\_terraform\_variable\_path](#input\_codepipeline\_source\_terraform\_variable\_path) | n/a | `string` | `""` | no |
| <a name="input_codepipeline_source_type"></a> [codepipeline\_source\_type](#input\_codepipeline\_source\_type) | n/a | `string` | `"S3"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_github_token"></a> [github\_token](#input\_github\_token) | n/a | `string` | `"pleasechangeme"` | no |
| <a name="input_github_webhook_secret"></a> [github\_webhook\_secret](#input\_github\_webhook\_secret) | n/a | `string` | `"pleasechangeme"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

## Outputs

No outputs.
