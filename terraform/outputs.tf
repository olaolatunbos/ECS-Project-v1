output "app_url" {
  description = "URL to reach the application through the ALB"
  value       = "http://${module.alb.alb_dns_name}"
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.alb.alb_dns_name
}

output "vpc_id" {
  description = "ID of the VPC"
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
