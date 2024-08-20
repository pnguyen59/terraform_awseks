output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "db_subnet" {
  description = "the subnet for db"
  value = module.vpc.database_subnets
}

output "db_subnet_group" {
  description = "the subnet for db"
  value = module.vpc.database_subnet_group
}

output "availability_zones" {
  description = "the availability zone"
  value = module.vpc.azs
}

output "vpc_applied" {
  description = "test"
  value = module.vpc.public_subnets
}
output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}