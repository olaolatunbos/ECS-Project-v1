locals {
  # Per-workspace settings. Select a workspace (staging or production) before
  # running plan/apply; an unrecognized workspace fails on the missing key.
  workspace_config = {
    staging = {
      vpc_cidr             = "10.10.0.0/16"
      public_subnet_cidrs  = ["10.10.0.0/24", "10.10.1.0/24"]
      private_subnet_cidrs = ["10.10.10.0/24", "10.10.11.0/24"]
      desired_count        = 1
      task_cpu             = "256"
      task_memory          = "512"
      image_repository_url = "801497981564.dkr.ecr.eu-west-2.amazonaws.com/staging/task-management"
      image_tag            = "latest"
      ecr_repository_name  = "staging/task-management"
    }
    production = {
      vpc_cidr             = "10.20.0.0/16"
      public_subnet_cidrs  = ["10.20.0.0/24", "10.20.1.0/24"]
      private_subnet_cidrs = ["10.20.10.0/24", "10.20.11.0/24"]
      desired_count        = 3
      task_cpu             = "512"
      task_memory          = "1024"
      image_repository_url = "801497981564.dkr.ecr.eu-west-2.amazonaws.com/production/task-management"
      image_tag            = "latest"
      ecr_repository_name  = "production/task-management"
    }
  }

  # Settings for the currently selected workspace.
  env = local.workspace_config[terraform.workspace]

  # Workspace-scoped name prefix keeps resource names unique across
  # environments deployed into the same account/region.
  name = "${var.name}-${terraform.workspace}"
}
