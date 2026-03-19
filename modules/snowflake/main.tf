terraform {
  required_providers {
    snowflake = {
      source  = "snowflake-labs/snowflake"
      version = "~> 0.87"
    }
  }
}

locals {
  env_prefix = var.env == "prd" ? "" : "${upper(var.env)}_"

  bi_role_name     = "${local.env_prefix}BI_ROLE"
  loader_role_name = "${local.env_prefix}LOADER_ROLE"
}

resource "snowflake_database" "db" {
  name = upper("tf_aws_sf_${var.env}_db")
}

locals {
  # 開発者別スキーマの定義
  developer_specific_suffixes = ["staging", "intermediate", "mart"]
  user_schemas = flatten([
    for user, details in var.developer_user_map : [
      for suffix in local.developer_specific_suffixes : {
        key     = "${suffix}_${user}"
        comment = "Private workspace for ${user}"
        owner   = "DEV_ROLE_${upper(user)}"
      }
    ]
  ])

  all_schemas = merge(
    { for k, v in var.schemas : k => { owner = "SYSADMIN", comment = v.comment } },
    { for s in local.user_schemas : s.key => { owner = s.owner, comment = s.comment } }
  )
}

resource "snowflake_account_role" "bi_role" { name = local.bi_role_name }
resource "snowflake_account_role" "loader_role" { name = local.loader_role_name }
resource "snowflake_account_role" "developer_role" {
  count = length(var.developer_user_map) > 0 ? 1 : 0
  name  = "DEVELOPER_ROLE"
}

resource "snowflake_account_role" "dev_developer_roles" {
  for_each = var.developer_user_map
  name     = "DEV_ROLE_${upper(each.key)}"
}

resource "snowflake_grant_account_role" "dev_inheritance" {
  for_each  = snowflake_account_role.dev_developer_roles
  role_name = each.value.name
  parent_role_name = snowflake_account_role.developer_role[0].name
}

resource "snowflake_warehouse" "this" {
  for_each = var.warehouses

  name              = "${local.env_prefix}${upper(each.key)}"
  warehouse_size    = each.value.size
  auto_suspend      = each.value.auto_suspend
  auto_resume       = true
  max_cluster_count = each.value.max_cluster_count
  min_cluster_count = each.value.min_cluster_count
}

locals {
  role_warehouse_mapping = {
    (local.bi_role_name)     = "${local.env_prefix}BI_WH"
    (local.loader_role_name) = "${local.env_prefix}LOADER_WH"
    "DEVELOPER_ROLE"         = "DEVELOPER_WH"
  }
}

resource "snowflake_grant_privileges_to_account_role" "common_wh_grants" {
  for_each = local.role_warehouse_mapping

  privileges        = ["USAGE"]
  account_role_name = each.key # ここで DEV_BI_ROLE 等が渡される
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.this[each.value].name
  }
}

resource "snowflake_schema" "this" {
  for_each                    = local.all_schemas
  database                    = snowflake_database.db.name
  name                        = upper(each.key)
  comment                     = each.value.comment
  data_retention_time_in_days = var.data_retention_time_in_days
}

resource "snowflake_grant_privileges_to_account_role" "dev_raw_future_grants" {
  count             = length(var.developer_user_map) > 0 ? 1 : 0
  privileges        = ["SELECT"]
  account_role_name = snowflake_account_role.developer_role[0].name
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = "${snowflake_database.db.name}.RAW"
    }
  }
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
  schema              = snowflake_schema.this["raw"].name
  storage_integration = snowflake_storage_integration.s3_int.name
}

resource "snowflake_file_format" "csv_no_header" {
  name                         = upper("csv_no_header_ff_${var.env}")
  database                     = snowflake_database.db.name
  schema                       = snowflake_schema.this["raw"].name
  format_type                  = "CSV"
  field_delimiter              = ","
  skip_header                  = 0
  null_if                      = ["NULL", ""]
  field_optionally_enclosed_by = "\""
}

resource "snowflake_external_table" "raw_s3_table" {
  database    = snowflake_database.db.name
  schema      = snowflake_schema.this["raw"].name
  name        = upper("ext_s3_raw_table_${var.env}")
  location    = "@${snowflake_database.db.name}.${snowflake_schema.this["raw"].name}.${snowflake_stage.external_stage.name}"
  file_format = "(${snowflake_database.db.name}.${snowflake_schema.this["raw"].name}.${snowflake_file_format.csv_no_header.name})"
  column {
    name = "ID"
    type = "NUMBER"
    as   = "VALUE:c1::NUMBER"
  }
  column {
    name = "DATA_VALUE2"
    type = "VARCHAR"
    as   = "VALUE:c2::VARCHAR"
  }
  column {
    name = "DATA_VALUE3"
    type = "VARCHAR"
    as   = "VALUE:c3::VARCHAR"
  }
  column {
    name = "DATA_VALUE4"
    type = "VARCHAR"
    as   = "VALUE:c4::VARCHAR"
  }
  column {
    name = "FILE_FULL_PATH"
    type = "VARCHAR"
    as   = "METADATA$FILENAME"
  }
  column {
    name = "LOADED_AT"
    type = "TIMESTAMP_NTZ"
    as   = "METADATA$START_SCAN_TIME"
  }
}
