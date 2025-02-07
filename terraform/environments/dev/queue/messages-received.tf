resource "aws_sqs_queue" "messages_received_dev" {
  name                       = "messages-received-dev"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
}

output "queue_arn" {
  value = aws_sqs_queue.messages_received_dev.arn
}

output "queue_url" {
  value = aws_sqs_queue.messages_received_dev.url
}