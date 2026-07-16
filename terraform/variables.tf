variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "name" {
  description = "Name prefix applied across the VPC, ALB, and ECS resources"
  type        = string
  default     = "prj1"
}

variable "hosted_zone_name" {
  description = "Route53 hosted zone the app hostnames live under"
  type        = string
  default     = "olaolat.com"
}


variable "container_port" {
  description = "Port the application container listens on (matches the Flask app)"
  type        = number
  default     = 3000
}
