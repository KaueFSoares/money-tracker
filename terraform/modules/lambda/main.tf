variable "function_name" {}
variable "handler" {}
variable "runtime" { default = "nodejs22.x" }
variable "memory_size" { default = 128 }
variable "timeout" { default = 10 }
variable "s3_bucket" {}
variable "s3_key" {}
variable "role" {}
variable "environment" {
  type    = map(string)
  default = {}
}


resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  role = var.role

  environment {
    variables = var.environment
  }
}
