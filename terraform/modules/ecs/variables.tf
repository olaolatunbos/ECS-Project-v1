variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "white-hart"
}

variable "container_insights" {
  description = "Whether CloudWatch Container Insights is enabled on the cluster"
  type        = string
  default     = "enabled"
}

variable "container_name" {
  description = "Name of the container in the task definition"
  type        = string
  default     = "app"
}

variable "task_family" {
  description = "Family name of the ECS task definition"
  type        = string
  default     = "service"
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "service"
}

variable "image_repository_url" {
  description = "ECR Public repository URI to pull the container image from, e.g. public.ecr.aws/<alias>/<repository>"
  type        = string
}

variable "image_tag" {
  description = "Tag of the image to pull from the ECR Public repository"
  type        = string
  default     = "latest"
}

variable "target_group_arn" {
  description = "ARN of the load balancer target group to register the service's tasks with"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC the ECS service's security group is created in"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC, used to scope the ECS service security group's ingress rule"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs the ECS service's tasks are placed in"
  type        = list(string)
}

variable "container_port" {
  description = "Port the application container listens on"
  type        = number
  default     = 3000
}

variable "task_cpu" {
  description = "Fargate task-level vCPU units"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Fargate task-level memory (MiB)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of task copies to run in the service"
  type        = number
  default     = 2
}
