output "database_sg" {
  value = module.database.rds-access
}

output "db_endpoint" {
  value = module.database.rds_endpoint
}
