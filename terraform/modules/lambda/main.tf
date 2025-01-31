variable "function_name" {}
variable "handler" {}
variable "runtime" { default = "nodejs22.x" }
variable "memory_size" { default = 128 }
variable "timeout" { default = 10 }
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

  role = var.role

  environment {
    variables = var.environment
  }
  
  publish = false
}

output "function_arn" {
  value = aws_lambda_function.this.arn
}
