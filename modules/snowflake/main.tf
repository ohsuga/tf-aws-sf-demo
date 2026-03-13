terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 0.87"
    }
  }
}

resource "snowflake_database" "db" {
  provider = snowflake.sys_admin
  name     = upper("tf_aws_sf_${var.env}_db")
}
