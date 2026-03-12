resource "aws_s3_bucket" "snowflake_raw_data" {
  bucket = "snowflake-raw-data-tf-aws-sf-${var.env}-20260310"
}
