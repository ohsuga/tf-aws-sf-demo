variable "env" {
  type        = string
  description = "実行環境 (dev, stg, prd)"
}
variable "storage_aws_role_arn" {
  type        = string
  description = "AWS側で作成したIAMロールのARN"
}

variable "bucket_name" {
  type = string
}

variable "target_directory" {
  type    = string
  default = "landing" # S3内の特定ディレクトリ
}

