resource "aws_sqs_queue" "messages_to_send_queue" {
  name                       = "messages-to-send-dev"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
}
