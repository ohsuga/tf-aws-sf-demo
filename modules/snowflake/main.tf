terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.87"
    }
  }
}

data "aws_secretsmanager_secret_version" "snowflake_key" {
  secret_id = "snowflake-infra/deploy-key/${var.env}"
}

provider "snowflake" {
  account       = var.snowflake_account
  user          = var.snowflake_user
  authenticator = "JWT"
  private_key   = data.aws_secretsmanager_secret_version.snowflake_key.secret_string
  alias = "sys_admin"
  role  = upper("tf_aws_sf_${var.env}_role")
}

resource "snowflake_database" "db" {
  provider = snowflake.sys_admin
  name     = upper("tf_aws_sf_${var.env}_db")
}
