output "vpc" {
  value = module.network.vpc
}
output "private_subnets" {
  value = module.network.private_subnets[*]
}

output "public_subnets" {
  value = module.network.public_subnets[*]
}
