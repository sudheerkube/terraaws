# Networking Outputs
output "vpc_id" {
  value = aws_vpc.auto_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.auto_rds_sng.*.name
}

output "db_security_group" {
  value = [aws_security_group.auto_sg["rds"].id]
}

output "public_sg" {
  value = aws_security_group.auto_sg["public"].id
}
output "public_subnet" {
  value = aws_subnet.auto_public_subnet.*.id
}