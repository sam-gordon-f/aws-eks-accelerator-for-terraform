locals {
    network_policies = distinct(
        flatten([
            for team_name, team in var.eks_teams: [
                for policy_name, policy in team.network_policies: {
                    egress = lookup(policy, "egress", {})
                    ingress = lookup(policy, "ingress", {})
                    name = policy_name
                    namespace = team_name
                    pod_selector = lookup(policy, "pod_selector", {})
                    policy_types = lookup(policy, "policy_types", [])
                }
            ]
        ]
    ))
}