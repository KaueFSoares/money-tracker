terraform {
  backend "s3" {
    bucket         = "terraform-stat"
    key            = "dev/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "terraform-lock"
  }
}