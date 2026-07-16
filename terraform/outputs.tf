output "app_url" {
  description = "HTTPS URL to reach the application"
  value       = "https://${local.env.hostname}"
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the Virtual Private Cloud (VPC)"
  value       = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.cluster_id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}
