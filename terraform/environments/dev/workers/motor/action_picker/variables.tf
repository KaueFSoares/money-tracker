variable "messages_to_send_queue_arn" {
  type = string
}

variable "messages_received_queue_arn" {
  type = string
}

variable "users_table_arn" {
  type = string
}

variable "users_table_gsi_arns" {
  type = list(string)
}

variable "lambda_bucket_id" {
  type = string
}

variable "messages_to_send_queue_url" {
  type = string
}

variable "aws_region" {
  type = string
}