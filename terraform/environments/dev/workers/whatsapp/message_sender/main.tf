resource "aws_iam_role" "message_sender_worker_role" {
  name = "message-sender-worker-dev-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = { Service = "lambda.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_policy" "message_sender_worker_policy" {
  name        = "message-sender-worker-dev-policy"
  description = "Allow sending messages to the to send messages queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.messages_to_send_queue_arn
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

resource "aws_iam_role_policy_attachment" "message_sender_worker_attachment" {
  role       = aws_iam_role.message_sender_worker_role.name
  policy_arn = aws_iam_policy.message_sender_worker_policy.arn
}

resource "aws_lambda_function" "message_sender_worker" {
  function_name = "message-sender-worker-dev"
  handler       = "index.handler"
  runtime       = "nodejs22.x"
  memory_size   = 128
  timeout       = 10

  s3_bucket = var.lambda_bucket_id
  s3_key    = "message-sender-worker-dev.zip"

  role = aws_iam_role.message_sender_worker_role.arn

  environment {
    variables = {
      GRAPH_API_TOKEN          = var.graph_api_token
      BUSINESS_PHONE_NUMBER_ID = var.business_phone_number_id
    }
  }
}

resource "aws_lambda_permission" "message_sender_sqs_invoke" {
  statement_id  = "AllowSQSInvokeMessageSender"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.message_sender_worker.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = var.messages_to_send_queue_arn
}

resource "aws_lambda_event_source_mapping" "message_sender_sqs_trigger" {
  event_source_arn = var.messages_to_send_queue_arn
  function_name    = aws_lambda_function.message_sender_worker.function_arn
  batch_size       = 1
}
