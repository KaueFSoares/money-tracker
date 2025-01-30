variable "table_name" {}
variable "billing_mode" { default = "PAY_PER_REQUEST" }
variable "read_capacity" { default = 5 }
variable "write_capacity" { default = 5 }
variable "hash_key" { default = "LockID" }
variable "attribute_type" { default = "S" }
variable "global_secondary_indexes" {
  type    = list(map(string))
  default = []
}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  hash_key     = var.hash_key

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value["name"]
      hash_key        = global_secondary_index.value["hash_key"]
      projection_type = global_secondary_index.value["projection_type"]
      read_capacity   = var.billing_mode != "PAY_PER_REQUEST" ? var.read_capacity : null
      write_capacity  = var.billing_mode != "PAY_PER_REQUEST" ? var.write_capacity : null
    }
  }

  dynamic "attribute" {
    for_each = toset(concat([var.hash_key], [for gsi in var.global_secondary_indexes : gsi["hash_key"]]))
    content {
      name = attribute.value
      type = var.attribute_type
    }
  }

  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode != "PAY_PER_REQUEST" ? var.read_capacity : null
  write_capacity = var.billing_mode != "PAY_PER_REQUEST" ? var.write_capacity : null

}


output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_name" {
  value = aws_dynamodb_table.this.name
}