output "queue_arn" {
  value = aws_sqs_queue.messages_to_send_queue.arn
}

output "queue_url" {
  value = aws_sqs_queue.messages_to_send_queue.url
}