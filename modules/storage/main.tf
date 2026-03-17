# S3 bucket for snowflake raw data
resource "aws_s3_bucket" "snowflake_raw_data" {
  bucket = "snowflake-raw-data-tf-aws-sf-${var.env}-20260310"
}

# Snowflake IAM role
resource "aws_iam_role" "snowflake_role" {
  name = "SnowflakeStorageRole-${var.env}"

  # set info from Snowflake STORAGE INTEGRATION
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.snowflake_iam_user_arn
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.snowflake_external_id
          }
        }
      }
    ]
  })
}

# Snowflake S3 access policy
resource "aws_iam_role_policy" "snowflake_s3_access" {
  name = "SnowflakeS3AccessPolicy"
  role = aws_iam_role.snowflake_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.snowflake_data.id}/${var.target_directory}*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::${aws_s3_bucket.snowflake_data.id}"
        Condition = {
          StringLike = {
            "s3:prefix" = ["${var.target_directory}*"]
          }
        }
      }
    ]
  })
}
