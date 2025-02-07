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

