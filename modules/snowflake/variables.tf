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

variable "warehouses" {
  type = map(object({
    size              = string
    auto_suspend      = number
    max_cluster_count = number
    min_cluster_count = number
  }))
  default = {
    "DEVELOPER_WH" = { size = "X-SMALL", auto_suspend = 60, max_cluster_count = 1, min_cluster_count = 1 }
    "BI_WH"        = { size = "X-SMALL", auto_suspend = 60, max_cluster_count = 1, min_cluster_count = 1 }
    "LOADER_WH"    = { size = "X-SMALL", auto_suspend = 60, max_cluster_count = 1, min_cluster_count = 1 }
  }
}

variable "schemas" {
  type = map(object({
    retention_days = number
    comment        = string
  }))
  description = "スキーマ名と各設定のマップ"
  default = {
    "raw" = {
      comment = "S3からのデータロード用スキーマ"
    },
    "staging" = {
      comment = "データクレンジング後の元データ配置用スキーマ"
    },
    "intermediate" = {
      comment = "結合後の中間テーブル配置用スキーマ"
    },
    "mart" = {
      comment = "BI向けデータマート配置用スキーマ"
    }
  }
}

variable "data_retention_time_in_days" {
  type        = number
  description = "Time Travelの保持日数 (days)"
  default     = 1
}

variable "developer_user_map" {
  type = map(object({
    email    = string
    password = string
  }))
  description = "ユーザー名をキーとし、メールアドレスと初期パスワードを持つマップ"
  sensitive   = true
}

variable "system_user_names" {
  type    = set(string)
  default = ["bi_user", "loader_user"]
}

