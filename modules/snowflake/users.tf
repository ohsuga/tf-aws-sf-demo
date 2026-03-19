resource "snowflake_user" "developer_users" {
  for_each = var.developer_user_map

  name         = upper(each.key)
  login_name   = upper(each.key)
  display_name = each.key

  email    = each.value.email
  password = each.value.password

  must_change_password = true

  default_role      = "DEV_ROLE_${upper(each.key)}"
  default_warehouse = "DEVELOPER_WH"

  # 既存ユーザーへのパスワード上書きを防止
  lifecycle {
    ignore_changes = [
      password,
    ]
  }
}

resource "snowflake_role_grants" "user_role_assignment" {
  for_each  = snowflake_user.developer_users
  role_name = "DEV_ROLE_${upper(each.key)}"
  users     = [each.value.name]

  depends_on = [snowflake_account_role.dev_developer_roles]
}
