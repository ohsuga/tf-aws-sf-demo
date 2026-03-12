terraform {
  backend "s3" {
    bucket         = "tf-aws-sf-dev-state-bucket-20260310" 
    key            = "aws-sf/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "tf-aws-sf-dev-lock-table-20260310"
    encrypt        = true
  }
}
