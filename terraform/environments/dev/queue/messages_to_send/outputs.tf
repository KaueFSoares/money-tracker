output "queue_arn" {
  value = aws_sqs_queue.messages_to_send.arn
}

output "queue_url" {
  value = aws_sqs_queue.messages_to_send.url
}