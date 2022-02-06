data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ---------------------------------------------------------------------------------------------------------------------
# Admin Password
# ---------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "admin_password" {
  count = var.admin_password_secret_name == "" ? 0 : 1
  name  = var.admin_password_secret_name
}

data "aws_secretsmanager_secret_version" "admin_password_version" {
  count     = var.admin_password_secret_name == "" ? 0 : 1
  secret_id = data.aws_secretsmanager_secret.admin_password[0].id
}

# ---------------------------------------------------------------------------------------------------------------------
# SSH Key
# ---------------------------------------------------------------------------------------------------------------------

data "aws_secretsmanager_secret" "ssh_key" {
  for_each = { for k, v in var.applications : k => v if v.ssh_key_secret_name != null }
  name     = each.value.ssh_key_secret_name
}

data "aws_secretsmanager_secret_version" "ssh_key_version" {
  for_each  = { for k, v in var.applications : k => v if v.ssh_key_secret_name != null }
  secret_id = data.aws_secretsmanager_secret.ssh_key[each.key].id
}
