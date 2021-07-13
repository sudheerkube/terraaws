# load balancer output

output "lb_target_group_arn" {
  value = aws_lb_target_group.auto_tg.arn
}

output "lb_endpoint" {
  value = aws_lb.auto_lb.dns_name
}