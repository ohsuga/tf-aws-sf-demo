variable "env" {
  type        = string
  description = "実行環境 (dev, stg, prd)"
}

variable "snowflake_account" {
  type        = string
  description = "Snowflake account identifier"
}

variable "snowflake_user" {
  type        = string
  description = "Snowflake user for CI/CD"
}
