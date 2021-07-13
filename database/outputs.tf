# db outputs

output "db_endpoint" {
  value = aws_db_instance.auto_db_inst.endpoint
}