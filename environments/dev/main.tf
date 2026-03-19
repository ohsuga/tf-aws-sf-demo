terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    snowflake = {
      source  = "snowflake-labs/snowflake"
      version = "~> 0.87"
    }
  }
}

module "storage" {
  source                 = "../../modules/storage"
  env                    = var.env
  snowflake_iam_user_arn = var.snowflake_iam_user_arn
  snowflake_external_id  = var.snowflake_external_id
}

data "aws_secretsmanager_secret_version" "snowflake_key" {
  secret_id = "snowflake-infra/deploy-key/${var.env}"
}

variable "snowflake_account_name" {}
variable "snowflake_organization_name" {}
variable "snowflake_user" {}

provider "snowflake" {
  account_name      = var.snowflake_account_name
  organization_name = var.snowflake_organization_name
  user              = var.snowflake_user
  authenticator     = "JWT"
  private_key       = data.aws_secretsmanager_secret_version.snowflake_key.secret_string
  alias             = "sys_admin"
  role              = upper("tf_aws_sf_${var.env}_role")
}

module "snowflake" {
  source = "../../modules/snowflake"
  env    = var.env
  providers = {
    snowflake = snowflake.sys_admin
  }
  developer_user_map          = var.developer_user_map
  storage_aws_role_arn        = module.storage.iam_role_arn
  bucket_name                 = module.storage.bucket_name
  data_retention_time_in_days = 1
}

output "real_snowflake_iam_user_arn" {
  value = module.snowflake.snowflake_iam_user_arn
}

output "real_snowflake_external_id" {
  value = module.snowflake.snowflake_external_id
}

