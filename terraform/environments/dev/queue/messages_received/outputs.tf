output "queue_arn" {
  value = aws_sqs_queue.messages_received.arn
}

output "queue_url" {
  value = aws_sqs_queue.messages_received.url
}