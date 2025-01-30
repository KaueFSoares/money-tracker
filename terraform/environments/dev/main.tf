module "messages_received_queue" {
  source     = "../../modules/sqs"
  queue_name = "messages-received-dev"
}

module "messages_to_send_queue" {
  source     = "../../modules/sqs"
  queue_name = "messages-to-send-dev"
}

module "users_table" {
  source         = "../../modules/dynamodb"
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
