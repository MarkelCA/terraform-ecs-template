output "private_subnets" {
  description = "List of private subnets"
  value       = module.vpc.private_subnets
}
