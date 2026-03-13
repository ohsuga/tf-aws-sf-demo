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
  source = "../../modules/storage"
  env    = var.env
}

data "aws_secretsmanager_secret_version" "snowflake_key" {
  secret_id = "snowflake-infra/deploy-key/${var.env}"
}

variable "snowflake_account" {}
variable "snowflake_user" {}

provider "snowflake" {
  account       = var.snowflake_account
  user          = var.snowflake_user
  authenticator = "JWT"
  private_key   = data.aws_secretsmanager_secret_version.snowflake_key.secret_string
  alias         = "sys_admin"
  role          = upper("tf_aws_sf_${var.env}_role")
}

module "snowflake" {
  source = "../../modules/snowflake"
  env    = var.env
  providers = {
    snowflake = snowflake.sys_admin
  }
}
