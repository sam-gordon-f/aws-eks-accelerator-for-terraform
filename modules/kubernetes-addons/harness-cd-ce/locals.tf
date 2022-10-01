locals {
  name         = "harness"

  default_helm_config = {
    name        = local.name
    repository  = "https://github.com/harness/harness-cd-community/tree/main/helm/harness"
    namespace   = local.name
    description = "Harness CD - community edition"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {

  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}