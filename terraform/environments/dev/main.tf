module "messages_received_queue" {
  source     = "../../modules/sqs"
  queue_name = "messages-received-dev"
}

module "messages_to_send_queue" {
  source     = "../../modules/sqs"
  queue_name = "messages-to-send-dev"
}
