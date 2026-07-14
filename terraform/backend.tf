terraform {
  backend "s3" {
    bucket       = "terraform-state-dbfa06d66e05a010"
    key          = "ecs-project/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
