resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "money-tracker-lambda-bucket"
}

module "messages_received_queue" {
  source     = "../../modules/sqs"
  queue_name = "messages-received-dev"
}

module "messages_to_send_queue" {
  source     = "../../modules/sqs"
  queue_name = "messages-to-send-dev"
}

module "users_table" {
  source         = "../../modules/dynamo_db"
  table_name     = "users"
  hash_key       = "userId"
  attribute_type = "S"
  billing_mode   = "PROVISIONED"

  global_secondary_indexes = [
    {
      name            = "phone-index"
      hash_key        = "phone"
      projection_type = "ALL"
    }
  ]
}

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
  s3_key        = "message-receiver-worker.zip"
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