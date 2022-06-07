#########
# Namespace(s)
#########

resource "kubernetes_namespace" "this" {
  for_each = var.eks_teams
  metadata {
    name   = each.key
    labels = each.value["labels"]
  }
}

###########
# Quota(s)
###########

resource "kubernetes_resource_quota" "compute_quota" {
  for_each = var.eks_teams
  metadata {
    name      = "compute-quota"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = each.value["compute_quota"]["requests.cpu"]
      "requests.memory" = each.value["compute_quota"]["requests.memory"]
      "limits.cpu"      = each.value["compute_quota"]["limits.cpu"]
      "limits.memory"   = each.value["compute_quota"]["limits.memory"]
    }
  }
}

resource "kubernetes_resource_quota" "object_quota" {
  for_each = var.eks_teams
  metadata {
    name      = "object-quota"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  spec {
    hard = {
      "pods"     = each.value["object_quota"]["pods"]
      "secrets"  = each.value["object_quota"]["secrets"]
      "services" = each.value["object_quota"]["services"]
    }
  }
}

###########
# Network Policy
###########

resource "kubernetes_network_policy" "default_deny_all" {
  for_each = var.eks_teams
  metadata {
    name      = "${each.key}-default"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  spec {
      # specify all apps
    pod_selector {}
      # limit all ingress traffic
    ingress {}
      # limit all egress traffic
    egress {}
      # limit all egress traffic
    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_network_policy" "network_policy" {
  for_each = { for policy in local.network_policies: "${policy.namespace}.${policy.name}" => policy }

  metadata {
    name      = "${each.value.namespace}-${each.value.name}"
    namespace = each.value["namespace"]
  }
  spec {
    egress {}
    # dynamic "egress" {
    #   for_each = each.value["egress"]
    #   content {}
    # }

    ingress {}
    # dynamic "ingress" {
    #   for_each = each.value["ingress"]
    #   content {}
    # }

    pod_selector {}
      # dynamic "match_expressions" {
      #   for_each = each.value["pod_selector"]["match_expressions"]
      #   content {
      #     key      = each.value["key"]
      #     operator = each.value["operator"]
      #     values   = each.value["values"]
      #   }
      # }
      # dynamic "match_labels" {
      #   for_each = each.value["pod_selector"]["match_labels"]
      #   content {
      #     key      = each.value["key"]
      #     operator = each.value["operator"]
      #     values   = each.value["values"]
      #   }

    policy_types = each.value["policy_types"]
  }
}

###########
# Proxy Config
###########

# resource "kubernetes_config_map" "proxy_settings" {
#   for_each = var.eks_teams
#   metadata {
#     name      = "proxy-settings"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
#   data = {
#     HTTP_PROXY  = "@TODO"
#     HTTPS_PROXY = "@TODO"
#     NO_PROXY    = "@TODO"
#   }
# }

###########
# IAM Roles
###########

resource "aws_iam_role" "editor" {
  for_each           = var.eks_teams
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  name = "${var.general.zone}-${each.key}-editor"  
  # permissions_boundary = var.permissions_boundary
  tags = var.general.tags
}

resource "aws_iam_role" "reader" {
  for_each           = var.eks_teams
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = data.aws_caller_identity.current.account_id
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
  name = "${var.general.zone}-${each.key}-reader"
  # permissions_boundary = var.permissions_boundary
  tags = var.general.tags
}

###########
# K8s Roles
###########

resource "kubernetes_cluster_role" "cluster" {
  for_each = var.eks_teams
  metadata {
    name = "${each.key}-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces", "nodes"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role" "editor" {
  for_each = var.eks_teams
  metadata {
    name      = "${each.key}-editor"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  rule {
    api_groups = ["*"]
    resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["resourcequotas"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role" "reader" {
  for_each = var.eks_teams
  metadata {
    name      = "${each.key}-reader"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  rule {
    api_groups = ["*"]
    resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["*"]
    resources  = ["resourcequotas"]
    verbs      = ["get", "list", "watch"]
  }
}

###########
# K8s Role binding
###########

resource "kubernetes_cluster_role_binding" "cluster" {
  for_each = var.eks_teams
  metadata {
    name = "${each.key}-cluster-role-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${each.key}-cluster-role"
  }
  subject {
    kind      = "Group"
    name      = "${each.key}-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_role_binding" "editor" {
  for_each = var.eks_teams
  metadata {
    name      = "${each.key}-editor-binding"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.editor[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "${kubernetes_namespace.this[each.key].metadata[0].name}-editors"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
}

resource "kubernetes_role_binding" "reader" {
  for_each = var.eks_teams
  metadata {
    name      = "${each.key}-reader-binding"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.reader[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "${kubernetes_namespace.this[each.key].metadata[0].name}-readers"
    api_group = "rbac.authorization.k8s.io"
    namespace = kubernetes_namespace.this[each.key].metadata[0].name
  }
}