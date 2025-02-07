// LAMBDA - MESSAGE RECEIVER WORKER

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
        Resource = module.messages_received_queue.queue_arn
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

module "message_receiver_worker" {
  source        = "../../modules/lambda"
  function_name = "message-receiver-worker-dev"
  handler       = "index.handler"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "message-receiver-worker-dev.zip"
  role          = aws_iam_role.message_receiver_worker_role.arn

  environment = {
    WEBHOOK_VERIFY_TOKEN = var.webhook_verify_token
    GRAPH_API_TOKEN      = var.graph_api_token
    SQS_QUEUE_URL        = module.messages_received_queue.queue_url
    REGION               = var.aws_region
  }
}

module "api_gateway" {
  source     = "../../modules/api_gateway"
  api_name   = "message-receiver-api-dev"
  lambda_arn = module.message_receiver_worker.function_arn
  aws_region = var.aws_region
}




// LAMBDA - ACTION PICKER

resource "aws_iam_role" "action_picker_worker_role" {
  name = "action-picker-worker-dev-role"

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

resource "aws_iam_policy" "action_picker_worker_policy" {
  name        = "action-picker-worker-dev-policy"
  description = "Allow sending messages to the to send messages queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:SendMessage"
        Resource = module.messages_to_send_queue.queue_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = module.messages_received_queue.queue_arn
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
        ]
        Resource = concat(
          [module.users_table.table_arn],
          module.users_table.gsi_arns
        )
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

resource "aws_iam_role_policy_attachment" "action_picker_worker_attachment" {
  role       = aws_iam_role.action_picker_worker_role.name
  policy_arn = aws_iam_policy.action_picker_worker_policy.arn
}

module "action_picker_worker" {
  source        = "../../modules/lambda"
  function_name = "action-picker-worker-dev"
  handler       = "index.handler"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "action-picker-dev.zip"
  role          = aws_iam_role.action_picker_worker_role.arn

  environment = {
    SQS_QUEUE_URL = module.messages_to_send_queue.queue_url
    REGION        = var.aws_region
  }
}

resource "aws_lambda_permission" "action_picker_sqs_invoke" {
  statement_id  = "AllowSQSInvokeActionPicker"
  action        = "lambda:InvokeFunction"
  function_name = module.action_picker_worker.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = module.messages_received_queue.queue_arn
}

resource "aws_lambda_event_source_mapping" "action_picker_sqs_trigger" {
  event_source_arn = module.messages_received_queue.queue_arn
  function_name    = module.action_picker_worker.function_arn
  batch_size       = 1
}



// LAMBDA - MESSAGE SENDER WORKER

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
        Effect   = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = module.messages_to_send_queue.queue_arn
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

module "message_sender_worker" {
  source        = "../../modules/lambda"
  function_name = "message-sender-worker-dev"
  handler       = "index.handler"
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = "message-sender-worker-dev.zip"
  role          = aws_iam_role.message_sender_worker_role.arn

  environment = {
    GRAPH_API_TOKEN = var.graph_api_token
    BUSINESS_PHONE_NUMBER_ID = var.business_phone_number_id
  }
}

resource "aws_lambda_permission" "message_sender_sqs_invoke" {
  statement_id  = "AllowSQSInvokeMessageSender"
  action        = "lambda:InvokeFunction"
  function_name = module.message_sender_worker.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = module.messages_to_send_queue.queue_arn
}

resource "aws_lambda_event_source_mapping" "message_sender_sqs_trigger" {
  event_source_arn = module.messages_to_send_queue.queue_arn
  function_name    = module.message_sender_worker.function_arn
  batch_size       = 1
}
