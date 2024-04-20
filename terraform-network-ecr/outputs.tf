output "vpc" {
  value = module.network.vpc
}
output "private_subnets" {
  value = module.network.private_subnets[*]
}

output "public_subnets" {
  value = module.network.public_subnets[*]
}

output "instance_profile" {
  value = module.ecr.instance-profile
}
