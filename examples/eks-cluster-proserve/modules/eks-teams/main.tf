#########
# Namespace
#########

resource "kubernetes_namespace" "this" {
  for_each = var.eks_teams
  metadata {
    name   = each.key
    labels = each.value["labels"]
  }
}

###########
# Quotas
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
# Network Policy (default)
###########

# resource "kubernetes_network_policy" "default_deny_all" {
#   for_each = var.eks_teams
#   metadata {
#     name      = "default-deny-all"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }

#   spec {
#     pod_selector {}
#     ingress {}
#     egress {}
#     policy_types = ["Ingress", "Egress"]
#   }
# }

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
# Roles
###########

# resource "aws_iam_role" "editor" {
#   for_each           = var.eks_teams
#   assume_role_policy = data.aws_iam_policy_document.iam_policy_document[each.key].json
#   name = "${var.general.environment}-${each.key}-editor"
#   # permissions_boundary = var.permissions_boundary
#   tags = var.general.tags
# }

# resource "aws_iam_role" "reader" {
#   for_each           = var.eks_teams
#   assume_role_policy = data.aws_iam_policy_document.iam_policy_document[each.key].json
#   name = "${var.general.environment}-${each.key}-reader"
#   # permissions_boundary = var.permissions_boundary
#   tags = var.general.tags
# }

# resource "kubernetes_role" "editor" {
#   for_each = var.eks_teams
#   metadata {
#     name      = "editor"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies"]
#     verbs      = ["get", "list", "watch", "create", "update", "patch", "delete", "deletecollection"]
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["resourcequotas"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_role" "reader" {
#   for_each = var.eks_teams
#   metadata {
#     name      = "reader"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["configmaps", "pods", "podtemplates", "secrets", "serviceaccounts", "services", "deployments", "horizontalpodautoscalers", "networkpolicies"]
#     verbs      = ["get", "list", "watch"]
#   }
#   rule {
#     api_groups = ["*"]
#     resources  = ["resourcequotas"]
#     verbs      = ["get", "list", "watch"]
#   }
# }

# resource "kubernetes_role_binding" "editor" {
#   for_each = var.eks_teams
#   metadata {
#     name      = "editor"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = kubernetes_role.k8s_role_editor[each.key].metadata[0].name
#   }
#   subject {
#     kind      = "Group"
#     name      = "${kubernetes_namespace.namespaces[each.key].metadata[0].name}-editors"
#     api_group = "rbac.authorization.k8s.io"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
# }

# resource "kubernetes_role_binding" "reader" {
#   for_each = var.eks_teams
#   metadata {
#     name      = "reader"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
#   role_ref {
#     api_group = "rbac.authorization.k8s.io"
#     kind      = "Role"
#     name      = kubernetes_role.k8s_role_reader[each.key].metadata[0].name
#   }
#   subject {
#     kind      = "Group"
#     name      = "${kubernetes_namespace.namespaces[each.key].metadata[0].name}-readers"
#     api_group = "rbac.authorization.k8s.io"
#     namespace = kubernetes_namespace.namespaces[each.key].metadata[0].name
#   }
# }