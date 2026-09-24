output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_rds_subnet_ids" {
  value = values(aws_subnet.rds_private)
}

output "private_app_subnet_ids" {
  value = values(aws_subnet.private)
}

output "public_subnet_ids" {
  value = values(aws_subnet.public_sn)
}

output "private_rds_route_table_id" {
  value = aws_route_table.private_rt.id
}

output "private_route_table_id" {
  value = aws_route_table.private_rt.id
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}