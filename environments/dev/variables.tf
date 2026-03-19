variable "env" {
  type    = string
  default = "dev"
}
variable "snowflake_iam_user_arn" {
  type    = string
  default = "dummy-iam-user-arn"
}
variable "snowflake_external_id" {
  type    = string
  default = "dummy-external-id"
}
variable "data_retention_time_in_days" {
  type        = number
  description = "Time Travelの保持日数(days)"
}

variable "developer_user_map" {
  type = map(object({
    email    = string
    password = string
  }))
  sensitive = true
}
