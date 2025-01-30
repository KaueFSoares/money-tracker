terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "prod/terraform.tfstate"
    region         = var.region
    dynamodb_table = "terraform-lock"
  }
}