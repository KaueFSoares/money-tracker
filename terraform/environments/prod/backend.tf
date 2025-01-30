terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-lock"
  }
}