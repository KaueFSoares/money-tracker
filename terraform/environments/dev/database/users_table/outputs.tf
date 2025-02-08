output "table_arn" {
  value = aws_dynamodb_table.users_table.arn
}

output "table_name" {
  value = aws_dynamodb_table.users_table.name
}

output "gsi_arns" {
  value = ["${aws_dynamodb_table.users_table.arn}/index/phone-index"]
}
