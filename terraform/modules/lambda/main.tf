variable "function_name" {}
variable "handler" {}
variable "runtime" { default = "nodejs22.x" }
variable "memory_size" { default = 128 }
variable "timeout" { default = 10 }
variable "s3_bucket" {}
variable "s3_key" {}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  runtime       = var.runtime
  memory_size   = var.memory_size
  timeout       = var.timeout

  s3_bucket = var.s3_bucket
  s3_key    = var.s3_key

  role = aws_iam_role.lambda_role.arn
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}
