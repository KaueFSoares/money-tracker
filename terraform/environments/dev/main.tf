
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