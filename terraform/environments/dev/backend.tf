terraform {
  backend "s3" {
    bucket         = "money-tracker-terraform-state"
    key            = "dev/terraform.tfstate"
    dynamodb_table = "terraform-lock"
  }
}