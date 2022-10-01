locals {
  name         = "harness"

  default_helm_config = {
    name        = local.name
    chart       = "https://github.com/harness/harness-cd-community/blob/main/helm/harness/Chart.yaml"
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