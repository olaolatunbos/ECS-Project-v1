output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "Public DNS name of the ALB (use this to reach the app)"
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Route 53 hosted zone ID of the ALB, for alias records"
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group to register the ECS service with"
  value       = aws_lb_target_group.this.arn
}

output "security_group_id" {
  description = "ID of the ALB's security group"
  value       = aws_security_group.alb.id
}

output "listener_arn" {
  description = "ARN of the ALB HTTP listener"
  value       = aws_lb_listener.this.arn
}
