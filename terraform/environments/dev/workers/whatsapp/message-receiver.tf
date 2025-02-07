resource "aws_iam_role" "message_receiver_worker_role" {
  name = "message-receiver-worker-dev-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "message_receiver_worker_policy" {
  name        = "message-receiver-worker-dev-policy"
  description = "Allow sending messages to the received messages queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.messages_received_queue.queue_arn
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "message_receiver_worker_attachment" {
  role       = aws_iam_role.message_receiver_worker_role.name
  policy_arn = aws_iam_policy.message_receiver_worker_policy.arn
}

resource "aws_lambda_function" "message_receiver_worker_dev" {
  function_name = "message-receiver-worker-dev"
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  memory_size   = 128
  timeout       = 10

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = "message-receiver-worker-dev.zip"

  role = aws_iam_role.message_receiver_worker_role.arn

  environment {
    variables = {
      WEBHOOK_VERIFY_TOKEN = var.webhook_verify_token
      GRAPH_API_TOKEN      = var.graph_api_token
      SQS_QUEUE_URL        = aws_sqs_queue.messages_received_queue.queue_url
      REGION               = var.aws_region
    }
  }
}

resource "aws_apigatewayv2_api" "message_receiver_api_dev" {
  name          = "message-receiver-api-dev"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.message_receiver_api_dev.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.message_receiver_worker.function_arn
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.message_receiver_api_dev.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.message_receiver_api_dev.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.message_receiver_worker.function_arn
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.message_receiver_api_dev.execution_arn}/*"
}

output "api_url" {
  value = aws_apigatewayv2_api.message_receiver_api_dev.api_endpoint
}

output "function_arn" {
  value = aws_lambda_function.message_receiver_worker_dev.arn
}

output "function_name" {
  value = aws_lambda_function.message_receiver_worker_dev.function_name
}