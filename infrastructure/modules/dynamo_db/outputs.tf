output "arn" {
  value = aws_dynamodb_table.driver_location.arn
}

output "table_name" {
  value = aws_dynamodb_table.driver_location.name
}