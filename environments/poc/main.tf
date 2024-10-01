provider "aws" {
  region = local.region
}

locals {
  name   = var.environment_name
  region = var.aws_region

  vpc_cidr       = var.vpc_cidr
  vpc_id = var.vpc_id
  tags = {
    Environment  = local.name
  }

  private_subnets = var.private_subnet_ids
  public_subnets = var.public_subnet_ids
  eks_subnets = var.eks_subnet_ids
  tag_val_public_subnet = "${local.name}-vpc-public-"
}



resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "aurora-db-subnet-group"
  description = "Subnet group for RDS instances"
  subnet_ids  = local.eks_subnets

  tags = {
    Name = "aurora-subnet-group"
  }
}




# module "aurora_db" {
#   source = "../../modules/aurora_msql"
#   db_subnet_group = aws_db_subnet_group.aurora_subnet_group.name
#   azs = ["ap-southeast-1a","ap-southeast-1b","ap-southeast-1c"]
#   vpc_id = local.vpc_id
# }


module "eks_iam" {
  source  = "../../modules/iam_eks"

  name        = "${local.name}-iam"

  tags        = local.tags
}

module "eks" {
  source = "../../modules/eks_cluster"
  environment = "blue"
  eks_admin_role_name = module.eks_iam.iam_arn
  vpc_id = var.vpc_id
  private_subnets = var.eks_subnet_ids
  cluster_version = "1.29"
  aws_region = local.region
  eks_addons  = [ {  "name"    = "coredns", 
                    "version" = "v1.11.1-eksbuild.4"},
                  {  "name"    = "aws-ebs-csi-driver", 
                    "version" = "v1.29.1-eksbuild.1"},
                  {  "name"    = "amazon-cloudwatch-observability", 
                    "version" = "v1.4.0-eksbuild.1"}]

  tags = local.tags
  name = "eks-cluster"
}


# module "redis-cluster" {
#   source = "../../modules/Redis_cluster"
#   private_subnets = var.private_subnet_ids
# }

module "aws_s3_bucket" {
  source = "../../modules/s3_bucket"
}

# module "aws_msk_cluster" {
#   source = "../../modules/Msk_cluster"
#   private_subnets = var.private_subnet_ids
# }