provider "aws" {
  region  = "us-west-1"
}

terraform {
  required_version = ">= 1.0"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state"
  region = "us-west-1"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  region       = "us-west-1"

  attribute {
    name = "LockID"
    type = "S"
  }
}