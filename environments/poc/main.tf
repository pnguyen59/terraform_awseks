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




# resource "aws_subnet" "eks_private_subnets" {
#  depends_on = [ module.vpc.vpc_applied ]
#  count             = length(var.eks_subnet_cidrs)
#  vpc_id            = module.vpc.vpc_id
#  cidr_block        = element(var.eks_subnet_cidrs, count.index)
#  availability_zone = element(module.vpc.availability_zones, count.index)
 
#  tags = {
#    Name = "eks-private-subnet-${count.index + 1}"
#  }
# }
# data "aws_subnets" "eks-list-subnet" {
#   filter {
#     name   = "tag:Name"
#     values = ["eks-private-subnet-*"]
#   }
# }
# data "aws_subnets" "public" {
#   filter {
#     name   = "tag:Name"
#     values = ["${local.tag_val_public_subnet}*"]
#   }
# }

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name        = "aurora-db-subnet-group"
  description = "Subnet group for RDS instances"
  subnet_ids  = local.eks_subnets

  tags = {
    Name = "aurora-subnet-group"
  }
}
# #Add Tags for the new cluster in the VPC Subnets
# resource "aws_ec2_tag" "private_subnets_eks" {
#   for_each    = toset(data.aws_subnets.eks-list-subnet.ids)
#   resource_id = each.value
#   key         = "kubernetes.io/cluster/${local.name}"
#   value       = "shared"
# }

# #Add Tags for the new cluster in the VPC Subnets
# resource "aws_ec2_tag" "public_subnets_eks" {
#   for_each    = toset(data.aws_subnets.eks-list-subnet.ids)
#   resource_id = each.value
#   key         = "kubernetes.io/cluster/${local.name}"
#   value       = "shared"
# }


module "aurora_db" {
  source = "../../modules/aurora_msql"
  db_subnet_group = aws_db_subnet_group.aurora_subnet_group.name
  azs = ["ap-southeast-1a","ap-southeast-1b","ap-southeast-1c"]
  vpc_id = local.vpc_id
}


module "eks_iam" {
  source  = "../../modules/iam_eks"

  name        = "${local.name}-iam"

  tags        = local.tags
}

module "eks" {
  source = "../../modules/eks_cluster"
  environment = "blue"
  eks_admin_role_name = module.eks_iam.iam_name
  vpc_id = var.vpc_id
  private_subnets = var.eks_subnet_ids
  cluster_version = "1.29"
  # public_subnets = module.vpc.public_subnets
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