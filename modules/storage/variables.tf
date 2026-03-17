variable "env" {
  type        = string
  description = "実行環境 (dev, stg, prd)"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "target_directory" {
  description = "Target directory path in the bucket (e.g., stage/data/)"
  devault     = "landing/"
  type        = string
}

variable "snowflake_iam_user_arn" {
  description = "IAM user ARN provided by Snowflake (DESC STORAGE INTEGRATION)"
  type        = string
}

variable "snowflake_external_id" {
  description = "External ID provided by Snowflake (DESC STORAGE INTEGRATION)"
  type        = string
}

