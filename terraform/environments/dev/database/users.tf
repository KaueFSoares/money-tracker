resource "aws_dynamodb_table" "users_table" {
  name         = "users"
  hash_key     = "userId"
  billing_mode = "PROVISIONED"

  read_capacity  = 5
  write_capacity = 5

  global_secondary_index {
    name            = "phone-index"
    hash_key        = "phone"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "phone"
    type = "S"
  }
}


output "table_arn" {
  value = aws_dynamodb_table.users_table.arn
}

output "table_name" {
  value = aws_dynamodb_table.users_table.name
}

output "gsi_arns" {
  value = [
    for gsi in [
      {
        name            = "phone-index"
        hash_key        = "phone"
        projection_type = "ALL"
      }
    ] : "${aws_dynamodb_table.users_table.arn}/index/${gsi["name"]}"
  ]
}
