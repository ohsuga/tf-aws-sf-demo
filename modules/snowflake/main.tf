terraform {
  required_providers {
    snowflake = {
      source  = "snowflake-labs/snowflake"
      version = "~> 0.87"
    }
  }
}

resource "snowflake_database" "db" {
  name = upper("tf_aws_sf_${var.env}_db")
}
