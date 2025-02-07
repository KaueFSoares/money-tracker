resource "aws_sqs_queue" "messages_to_send" {
  name                       = "messages-to-send-dev"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
}

output "queue_arn" {
  value = aws_sqs_queue.messages_to_send.arn
}

output "queue_url" {
  value = aws_sqs_queue.messages_to_send.url
}