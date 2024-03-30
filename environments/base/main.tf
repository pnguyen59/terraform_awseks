provider "aws" {
  region = local.region
}

locals {
  name   = var.environment_name
  region = var.aws_region

  vpc_cidr       = var.vpc_cidr
  
  tags = {
    Environment  = local.name
  }
}


module "vpc" {
  source  = "../../modules/vpc"

  name        = "${local.name}-vpc"

  vpc_cidr    = local.vpc_cidr
  aws_region  = local.region

  tags        = local.tags
}
