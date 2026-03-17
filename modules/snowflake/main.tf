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

resource "snowflake_storage_integration" "s3_int" {
  name                      = upper("s3_int_${var.env}")
  type                      = "EXTERNAL_STAGE"
  storage_provider          = "S3"
  enabled                   = true
  storage_aws_role_arn      = var.storage_aws_role_arn
  storage_allowed_locations = ["s3://${var.bucket_name}/${var.target_directory}/"]
}

resource "snowflake_stage" "external_stage" {
  name                = upper("ext_stage_${var.env}")
  url                 = "s3://${var.bucket_name}/${var.target_directory}/"
  database            = snowflake_database.db.name
  schema              = "PUBLIC"
  storage_integration = snowflake_storage_integration.s3_int.name
}

