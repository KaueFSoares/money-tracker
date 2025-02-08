resource "aws_sqs_queue" "messages_received_queue" {
  name                       = "messages-received-dev"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
}
