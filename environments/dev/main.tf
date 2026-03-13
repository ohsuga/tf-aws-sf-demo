variable "snowflake_account" {}
variable "snowflake_user" {}

module "storage" {
  source = "../../modules/storage"
  env    = var.env
}

module "snowflake" {
  source = "../../modules/snowflake"
  env    = var.env
}
