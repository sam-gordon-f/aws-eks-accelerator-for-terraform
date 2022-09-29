locals {
  name         = "harness"

  default_helm_config = {
    name        = local.name
    chart       = "harness"
    repository  = "https://helm-charts.newrelic.com"
    version     = "4.8.10"
    namespace   = local.name
    description = "New Relic"
    values      = local.default_helm_values
    timeout     = "1200"
  }

  default_helm_values = [templatefile("${path.module}/values.yaml", {
    licenseKey  = var.license_key
    cluster     = var.addon_context.eks_cluster_id
  })]

  helm_config = merge(
    local.default_helm_config,
    var.helm_config
  )

  argocd_gitops_config = {
    enable = true
  }
}