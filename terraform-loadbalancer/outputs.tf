output "dns-name" {
  value = module.loadbalancer.load-balancer-dns-name
}

output "load-balancer-target-group" {
  description = "target group of the load balancer"
  value = module.loadbalancer.load-balancer-target-group
}
