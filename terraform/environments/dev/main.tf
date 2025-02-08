
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
}

module "message_receiver" {
  source = "./workers/whatsapp/message_receiver"
}

module "message_sender" {
  source = "./workers/whatsapp/message_sender"
}