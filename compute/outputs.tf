#--Compute outputs

output "instance" {
  value     = aws_instance.auto_node[*]
  sensitive = true
}

output "instance_port" {
  value = aws_lb_target_group_attachment.auto_lb_attach[0].port
}