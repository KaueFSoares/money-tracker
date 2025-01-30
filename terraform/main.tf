provider "aws" {
  region  = var.aws_region
}

terraform {
  required_version = ">= 1.0"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}