variable "region" {
  default = "us-west-1"
}

// storage

module "lambda_bucket" {
  source = "./storage/lambda_bucket"
}

// database

module "users_table" {
  source = "./database/users_table"
}


// queue

module "messages_received" {
  source = "./queue/messages_received"
}

module "messages_to_send" {
  source = "./queue/messages_to_send"
}


// worker

module "action_picker" {
  source = "./workers//motor/action_picker"

  messages_to_send_queue_arn  = module.messages_to_send.queue_arn
  messages_received_queue_arn = module.messages_received.queue_arn
  users_table_arn             = module.users_table.table_arn
  users_table_gsi_arns        = module.users_table.gsi_arns
  lambda_bucket_id            = module.lambda_bucket.id

  messages_to_send_queue_url = module.messages_to_send.queue_url
  aws_region                 = var.region
}

module "message_receiver" {
  source = "./workers/whatsapp/message_receiver"

  messages_received_queue_arn = module.messages_received.queue_arn
  lambda_bucket_id            = module.lambda_bucket.id
  messages_received_queue_url = module.messages_received.queue_url
  aws_region                  = var.region
  webhook_verify_token        = var.webhook_verify_token
  graph_api_token             = var.graph_api_token
}

module "message_sender" {
  source = "./workers/whatsapp/message_sender"

  messages_to_send_queue_arn = module.messages_to_send.queue_arn
  lambda_bucket_id           = module.lambda_bucket.id
  aws_region                 = var.region
  graph_api_token            = var.graph_api_token
  business_phone_number_id   = var.business_phone_number_id
}