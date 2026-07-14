variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "name" {
  description = "Name prefix applied across the VPC, ALB, and ECS resources"
  type        = string
  default     = "ecs-project"
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository to create (matches the repo CI pushes to)"
  type        = string
  default     = "ecs/task-management"
}

variable "image_repository_url" {
  description = "ECR Public repository URI to pull the container image from, e.g. public.ecr.aws/<alias>/<repository>"
  type        = string
}

variable "image_tag" {
  description = "Tag of the container image to deploy"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Port the application container listens on (matches the Flask app)"
  type        = number
  default     = 80
}

# desired_count, task_cpu, and task_memory are defined per-workspace in
# locals.tf (local.workspace_config), so they are not root variables.
