output "connection_string_secret_arn" {
  value = aws_secretsmanager_secret.connection_string.arn
}
output "replica_connection_string_arns" {
  value = tomap({ for key, value in aws_secretsmanager_secret_version.replica_connection_string : key => value.arn })
}
output "connection_details_secret_arn" {
  # FYI - output is in JSON format
  value = aws_secretsmanager_secret.password.arn
}

output "address" {
  value = aws_db_instance.database.address
}

output "port" {
  value = aws_db_instance.database.port
}

output "db_name" {
  value = aws_db_instance.database.db_name
}

output "master_username" {
  value = aws_db_instance.database.username
}
output "master_password" {
  value = aws_db_instance.database.password
}

output "connection_address" {
  value = var.use_proxy ? aws_db_proxy.proxy[0].endpoint : aws_db_instance.database.address
}