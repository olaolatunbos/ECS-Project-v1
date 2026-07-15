module "ecr" {
  source = "./modules/ecr"

  name = local.env.ecr_repository_name
}

module "vpc" {
  source = "./modules/vpc"

  name                 = local.name
  vpc_cidr             = local.env.vpc_cidr
  public_subnet_cidrs  = local.env.public_subnet_cidrs
  private_subnet_cidrs = local.env.private_subnet_cidrs
}

module "alb" {
  source = "./modules/alb"

  name              = local.name
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  listener_port     = 80
  target_port       = var.container_port
  health_check_path = "/health"
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name = local.name

  image_repository_url = local.env.image_repository_url
  image_tag            = local.env.image_tag

  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids

  target_group_arn = module.alb.target_group_arn
  container_port   = var.container_port
  desired_count    = local.env.desired_count
  task_cpu         = local.env.task_cpu
  task_memory      = local.env.task_memory

  # Ensure the ALB listener/target group are fully wired before ECS
  # registers the service against the target group.
  depends_on = [module.alb]
}
