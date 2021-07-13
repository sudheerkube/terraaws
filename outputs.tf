# root outputs

output "load_balancer_endpoint" {
  value = module.loadbalancer.lb_endpoint
}

output "instance" {
  value     = { for i in module.compute.instance : i.tags.Name => "${i.public_ip}:${module.compute.instance_port}" }
  sensitive = true

}

output "kubeconfig" {
  value = [for i in module.compute.instance : "export KUBECONFIG=../k3-${i.tags.Name}.yaml"]
  sensitive = true
}