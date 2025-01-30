terraform {
  backend "s3" {
    bucket         = "money-tracker-terraform-state"
    key            = "prod/terraform.tfstate"
    dynamodb_table = "terraform-lock"
  }
}