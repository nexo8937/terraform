output "load-balancer-dns-name" {
  description = "DNS name of the load balancer"
  value = aws_lb.load-balancer.dns_name
}
