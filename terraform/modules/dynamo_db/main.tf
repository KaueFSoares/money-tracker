variable "table_name" {}
variable "billing_mode" { default = "PROVISIONED" }
variable "read_capacity" { default = 5 }
variable "write_capacity" { default = 5 }
variable "hash_key" { default = "LockID" }
variable "attribute_type" { default = "S" }
variable "global_secondary_indexes" {
  type    = list(map(string))
  default = []
}

resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  hash_key       = var.hash_key

  global_secondary_indexes = [
    {
      name            = "phone-index"
      hash_key        = "phone"
      projection_type = "ALL"
    }
  ]

  dynamic "attribute" {
    for_each = [var.hash_key]
    content {
      name = attribute.value
      type = var.attribute_type
    }
  }

  dynamic "provisioned_throughput" {
    for_each = var.billing_mode == "PROVISIONED" ? [1] : []
    content {
      read_capacity  = var.read_capacity
      write_capacity = var.write_capacity
    }
  }
}

output "table_arn" {
  value = aws_dynamodb_table.this.arn
}

output "table_name" {
  value = aws_dynamodb_table.this.name
}