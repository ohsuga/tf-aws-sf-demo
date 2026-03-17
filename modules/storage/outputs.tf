output "iam_role_arn" {
  value = aws_iam_role.snowflake_role.arn
}

output "bucket_name" {
  value = aws_s3_bucket.snowflake_raw_data.bucket
}
