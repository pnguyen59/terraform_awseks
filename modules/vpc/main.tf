data "aws_availability_zones" "available" {
   state = "available"
}


locals {
  name   = var.name
  region = var.aws_region

  vpc_cidr       = var.vpc_cidr
  num_of_subnets = min(length(data.aws_availability_zones.available.names), 3)
  azs            = slice(data.aws_availability_zones.available.names, 0, local.num_of_subnets)

  tags = merge(
    {Template = "base vpc module"},
    var.tags
  )
  private_sub = var.private_subnet_cidrs
  public_sub = var.public_subnet_cidrs 
  eks_sub =  var.eks_subnet_cidrs
  aurora_db_subnet= var.aurora_db_subnet
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = local.public_sub
  private_subnets = local.private_sub

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
  database_subnets = local.aurora_db_subnet
  database_subnet_group_name = "aurora-group"
}

module "aurora" {
  source = "../aurora_msql"
  db_subnet_group = module.vpc.database_subnet_group_name
  vpc_id = module.vpc.vpc_id
  azs = module.vpc.azs
}



