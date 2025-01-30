terraform {
  backend "s3" {
    bucket         = "terraform-stat"
    key            = "dev/terraform.tfstate"
    region         = var.region
    dynamodb_table = "terraform-lock"
  }
}