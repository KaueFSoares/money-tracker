output "api_url" {
  value = aws_apigatewayv2_api.message_receiver_api.api_endpoint
}

output "function_arn" {
  value = aws_lambda_function.message_receiver_worker.arn
}

output "function_name" {
  value = aws_lambda_function.message_receiver_worker.function_name
}