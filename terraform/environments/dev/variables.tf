variable "webhook_verify_token" {
  type      = string
  sensitive = true
}
variable "graph_api_token" {
  type      = string
  sensitive = true
}
variable "aws_region" {
  default = "us-west-1"
}