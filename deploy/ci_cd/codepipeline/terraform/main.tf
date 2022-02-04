####
# Source: S3
####

resource "aws_s3_bucket" "source_cluster_s3" {
  count = var.codepipeline_source_type == "S3" ? 1 : 0

  bucket = format("%s-%s-codepipeline-source-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  acl  = "private"
  tags = var.tags
  policy = templatefile("files/s3_bucket_policy_codepipeline_pipeline.tpl", {
    resource_arn = format("arn:aws:s3:::%s-%s-codepipeline-source-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  })
  versioning {
    enabled = true
  }
}

####
# Source: Bitbucket
####

resource "aws_codestarconnections_connection" "source_cluster_bitbucket" {
  count = var.codepipeline_source_type == "Bitbucket" ? 1 : 0

  name          = var.environment
  provider_type = "Bitbucket"
}

####
# Source: GitHub
####

resource "aws_codestarconnections_connection" "source_cluster_github" {
  count = var.codepipeline_source_type == "GitHub" ? 1 : 0

  name          = var.environment
  provider_type = "GitHub"
}

resource "aws_codepipeline_webhook" "codepipeline_webhook_github" {
  count = var.codepipeline_source_type == "GitHub" ? 1 : 0

  name            = var.environment
  authentication  = "GITHUB_HMAC"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.this.name

  authentication_configuration {
    secret_token = var.github_webhook_secret
  }
  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/master"
  }
}

# resource "github_repository_webhook" "github_webhook" {
#   count = var.codepipeline_source_type == "GitHub" ? 1 : 0

#   repository = var.codepipeline_source_repo_name
#   configuration {
#     url          = aws_codepipeline_webhook.codepipeline_webhook_github[0].url
#     content_type = "json"
#     insecure_ssl = true
#     secret       = var.github_webhook_secret
#   }
#   events = ["push"]
# }

####
# Source: GitHubEnterpriseServer
####

resource "aws_codestarconnections_connection" "source_cluster_github_enterprise_server" {
  count = var.codepipeline_source_type == "GitHubEnterpriseServer" ? 1 : 0

  name          = var.environment
  provider_type = "GitHubEnterpriseServer"
}

####
# Source: CodeCommit
####

resource "aws_codecommit_repository" "source_cluster_codecommit" {
  repository_name = var.environment
  default_branch = "master"
}

####
# Post codepipeline lambda resources
####

resource "aws_iam_role" "post-codepipeline-lambda" {
  name = format("lambda-%s", var.environment)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name   = "lambda"
    policy = file("${path.module}/files/iam_policy_lambda_function_post_codepipeline.json")
  }
  tags = var.tags
}

resource "aws_cloudwatch_log_group" "post-codepipeline-lambda" {
  name              = "/aws/lambda/${var.environment}"
  retention_in_days = 14
}

resource "aws_lambda_function" "post-codepipeline-lambda" {
  filename      = data.archive_file.post-codepipeline-lambda.output_path
  function_name = format("%s-codepipeline-post-apply", var.environment)
  role          = aws_iam_role.post-codepipeline-lambda.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = "${data.archive_file.post-codepipeline-lambda.output_base64sha256}"
  runtime = "python3.8"
}

####
# Codepipeline Resources
####

resource "aws_s3_bucket" "artefacts" {
  bucket = format("%s-%s-codepipeline-artefacts-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  acl  = "private"
  policy = templatefile("files/s3_bucket_policy_codepipeline_pipeline.tpl", {
    resource_arn = format("arn:aws:s3:::%s-%s-codepipeline-artefacts-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  })  
  tags = var.tags
}

resource "aws_s3_bucket" "logs" {
  bucket = format("%s-%s-codepipeline-logs-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  acl  = "private"
  policy = templatefile("files/s3_bucket_policy_codepipeline_pipeline.tpl", {
    resource_arn = format("arn:aws:s3:::%s-%s-codepipeline-logs-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  })
  tags = var.tags
}

resource "aws_s3_bucket" "tf_state" {
  bucket = format("%s-%s-codepipeline-tf-state-%s", data.aws_caller_identity.current.account_id, data.aws_region.current.name, var.environment)
  acl  = "private"
  tags = var.tags
  versioning {
    enabled = true
  }
}

resource "aws_iam_role" "codepipeline" {
  name = format("codepipeline-%s", var.environment)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name   = "codepipeline"
    policy = file("${path.module}/files/iam_policy_codepipeline_pipeline.json")
  }

  tags = var.tags
}

resource "aws_iam_role" "codebuild" {
  name = format("codebuild-%s", var.environment)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    name   = "codebuild"
    policy = file("${path.module}/files/iam_policy_codebuild_project.json")
  }

  tags = var.tags
}

resource "aws_security_group" "codebuild" {
  name        = format("codebuild-%s", var.environment)
  description = "Allow codebuild"
  vpc_id      = var.codebuild_project_ec2_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "test_checkov" {
  name          = format("%s-test-checkov", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/test_checkov.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "test_tfsec" {
  name          = format("%s-test-tfsec", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }
    
    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/test_tfsec.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "test_tflint" {
  name          = format("%s-test-tflint", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/test_tflint.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "test_terrascan" {
  name          = format("%s-test-terrascan", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/test_terrascan.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "test_conftest" {
  name          = format("%s-test-conftest", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/test_conftest.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "plan" {
  name          = format("%s-plan", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/plan.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "apply" {
  name          = format("%s-apply", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/apply.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codebuild_project" "destroy" {
  name          = format("%s-destroy", var.environment)
  build_timeout = "30"
  service_role  = aws_iam_role.codebuild.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_NAME"
      value = aws_s3_bucket.tf_state.id
    }

    environment_variable {
      name  = "TF_STATE_S3_BUCKET_KEY"
      value = "terraform.tfstate"
    }

    environment_variable {
      name  = "AWS_REGION"
      value = data.aws_region.current.name
    }

    environment_variable {
      name  = "TF_PATH"
      value = var.codepipeline_source_terraform_path
    }

    environment_variable {
      name  = "TF_VARIABLE_PATH"
      value = var.codepipeline_source_terraform_variable_path
    }
  }

  logs_config {
    s3_logs {
      status   = "ENABLED"
      location = "${aws_s3_bucket.logs.id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
    buildspec = file("../buildspec/destroy.yml")
  }

  vpc_config {
    vpc_id = var.codebuild_project_ec2_vpc_id
    subnets = var.codebuild_project_list_ec2_subnet_id
    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }

  tags = var.tags
}

resource "aws_codepipeline" "this" {
  name     = var.environment
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artefacts.id
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = local.codepipeline_source_configuration.name
      category         = "Source"
      owner            = "AWS"
      provider         = local.codepipeline_source_configuration.provider
      version          = "1"
      output_artifacts = ["source_output"]
      configuration    = local.codepipeline_source_configuration.configuration
    }
  }

  stage {
    name = "Plan"
    action {
      name             = "terraform_plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [
        "source_output"
      ]
      output_artifacts = [
        "build_terraform_plan_output"
      ]
      version          = "1"
      configuration = {
        PrimarySource = "source_output"
        ProjectName = aws_codebuild_project.plan.name
      }
      namespace = "build_terraform_plan"
    }
  }

  dynamic "stage" {
    for_each = var.codepipeline_include_test_stage == true ? [1] : []
    content {
      name = "Test"
      action {
        name             = "checkov"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = [
          "build_terraform_plan_output"
        ]
        version          = "1"
        configuration = {
          PrimarySource = "build_terraform_plan_output"
          ProjectName = aws_codebuild_project.test_checkov.name
        }
        namespace = "build_test_checkov"
      }
      action {
        name             = "tfsec"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = [
          "build_terraform_plan_output"
        ]
        version          = "1"
        configuration = {
          PrimarySource = "build_terraform_plan_output"
          ProjectName = aws_codebuild_project.test_tfsec.name
        }
        namespace = "build_test_tfsec"
      }
      action {
        name             = "tflint"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = [
          "build_terraform_plan_output"
        ]
        version          = "1"
        configuration = {
          PrimarySource = "build_terraform_plan_output"
          ProjectName = aws_codebuild_project.test_tflint.name
        }
        namespace = "build_test_tflint"
      }
      action {
        name             = "terrascan"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = [
          "build_terraform_plan_output"
        ]
        version          = "1"
        configuration = {
          PrimarySource = "build_terraform_plan_output"
          ProjectName = aws_codebuild_project.test_terrascan.name
        }
        namespace = "build_test_terrascan"
      }
      action {
        name             = "conftest"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = [
          "build_terraform_plan_output"
        ]
        version          = "1"
        configuration = {
          PrimarySource = "build_terraform_plan_output"
          ProjectName = aws_codebuild_project.test_conftest.name
        }
        namespace = "build_test_conftest"
      }
    }
  }

  stage {
    name = "Approve"

    dynamic "action" {
      for_each = var.codepipeline_include_test_stage == true ? [1] : []
      content {
        name     = "test_frameworks"
        category = "Approval"
        owner    = "AWS"
        provider = "Manual"
        version  = "1"
        configuration = {
          # NotificationArn = "${var.approve_sns_arn}"
          CustomData = "tfsec errors: #{build_test_tfsec.TEST_ERRORS}\ntflint errors: #{build_test_tflint.TEST_ERRORS}\ncheckov errors: #{build_test_checkov.TEST_ERRORS}\nterrascan failures: #{build_test_terrascan.TEST_ERRORS}\nconftest failures: #{build_test_conftest.TEST_ERRORS}"
          # ExternalEntityLink = "${var.approve_url}"    
          # external_entity_link = "https://#{TFSEC.Region}.console.aws.amazon.com/codesuite/codebuild/"+core.Stack.of(self).account+"/projects/#{TFSEC.BuildID}/build/#{TFSEC.BuildID}%3A#{TFSEC.BuildTag}/?region=#{TFSEC.Region}",
        }
      }
    }
    action {
      name     = "terraform_plan"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
      configuration = {
        # NotificationArn = "${var.approve_sns_arn}"
        CustomData = "Please review the tf plan from the below link"
        ExternalEntityLink = join("", [
          "https://",
          data.aws_region.current.name,
          ".console.aws.amazon.com/codesuite/codebuild/",
          data.aws_caller_identity.current.account_id,
          "/projects/",
          var.environment,
          "-plan/build/",
          "#{build_terraform_plan.CODEBUILD_BUILD_ID}/?region=",
          data.aws_region.current.name
        ])
      }
    }
  }

  stage {
    name = "Apply"
    action {
      name             = "terraform_apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [
        "build_terraform_plan_output"
      ]
      version          = "1"
      configuration = {
        PrimarySource = "build_terraform_plan_output"
        ProjectName = aws_codebuild_project.apply.name
      }
      namespace = "build_terraform_apply"
    }
  }

  stage {
    name = "Post_Apply"
    action {
      name             = "lambda"
      category         = "Invoke"
      owner            = "AWS"
      provider         = "Lambda"
      version          = "1"

      configuration = {
        FunctionName = aws_lambda_function.post-codepipeline-lambda.function_name
        # UserParameters = {}
      }
    }
  }

  dynamic "stage" {
    for_each = var.codepipeline_include_destroy_stage == true ? [1] : []
    content {
      name = "Destroy"
      action {
        name             = "terraform_destroy"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = [
          "source_output"
        ]
        output_artifacts = ["destroy_output"]
        version          = "1"
        configuration = {
          PrimarySource = "source_output"
          ProjectName = aws_codebuild_project.destroy.name
        }
        namespace = "build_terraform_destroy"
      }
    }
  }
}