module "s3_backend" {
  source              = "./modules/s3_backend"
  bucket_name         = "your-terraform-state-bucket"
  dynamodb_table_name = "terraform-lock-table"
}

module "network" {
  source     = "./modules/network"
  depends_on = [module.s3_backend]
}

module "ecr" {
  source     = "./modules/ecr"
  depends_on = [module.s3_backend]
}

module "ecs" {
  source     = "./modules/ecs"
  depends_on = [module.network, module.ecr]
}

module "sns" {
  source     = "./modules/sns"
  depends_on = [module.s3_backend]
}

module "lambda" {
  source     = "./modules/lambda"
  depends_on = [module.sns]
}

module "eventbridge" {
  source     = "./modules/eventbridge"
  depends_on = [module.lambda]
}

module "network" {
  source               = "./modules/network"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
  depends_on           = [module.s3_backend]
}
module "ecr" {
  source          = "./modules/ecr"
  repository_name = "springboot-petclinic-ecr"
  depends_on      = [module.s3_backend]
}

module "ecs" {
  source            = "./modules/ecs"
  cluster_name      = "ecs-fargate-cluster"
  task_name         = "springboot-petclinic-task"
  container_name    = "springboot-petclinic-container"
  container_port    = 8080
  ecr_repository_url = module.ecr.repository_url
  vpc_id            = module.network.vpc_id
  subnet_ids        = module.network.public_subnet_ids
  security_group_id = module.network.ecs_security_group_id
  depends_on        = [module.ecr, module.network]
}

module "sns" {
  source        = "./modules/sns"
  topic_name    = "deployment-notification-topic"
  email_address = "your-email@example.com"  # Replace with your email
  depends_on    = [module.s3_backend]
}
