locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "./modules/networking"

  region                       = var.region
  profile                      = var.profile
  vpc_cidr                     = var.vpc_cidr
  public_subnets_cidr          = var.public_subnets_cidr
  private_subnets_cidr         = var.private_subnets_cidr
  public_route_table_id        = var.public_route_table_id
  availability_zones           = local.production_availability_zones
  public_subnet_id             = [module.networking.public_subnet_id[0], module.networking.public_subnet_id[1], module.networking.public_subnet_id[2]]
  public_internet_gateway_cidr = var.public_internet_gateway_cidr

}

module "s3" {
  source = "./modules/s3"
}

module "instance" {

  source = "./modules/instance"

  ami_id            = var.ami_id
  region            = var.region
  key_pair          = var.key_pair
  vpc_id            = module.networking.vpc_id
  public_subnet_id  = module.networking.public_subnet_id
  private_subnet_id = module.networking.private_subnet_id
  application_port  = var.application_port
  database_username = var.database_username
  database_password = var.database_password
  database_name     = var.database_name
  ec2_iam_role      = module.s3.ec2_iam_role
  bucket_name       = module.s3.bucket_name
  domain_root       = var.domain_root
  profile           = var.profile
  log_group_name    = var.log_group_name

}

