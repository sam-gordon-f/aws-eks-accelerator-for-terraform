locals {
  name         = "harness"

  default_helm_config = {
    name        = local.name
    chart       = "harness-prod"
    repository  = "https://harness.github.io/helm-charts"
    version     = "0.2.54"
    namespace   = local.name
    description = "Harness"
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