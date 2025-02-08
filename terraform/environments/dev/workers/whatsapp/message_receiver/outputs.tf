output "api_url" {
  value = aws_apigatewayv2_api.message_receiver_api_dev.api_endpoint
}

output "function_arn" {
  value = aws_lambda_function.message_receiver_worker_dev.arn
}

output "function_name" {
  value = aws_lambda_function.message_receiver_worker_dev.function_name
}