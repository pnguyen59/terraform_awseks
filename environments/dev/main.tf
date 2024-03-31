provider "aws" {
  region = local.region
}

locals {
  name   = var.environment_name
  region = var.aws_region

  cluster_name = var.cluster_name
  eks_admin_role_name = var.eks_admin_role_name
  vpc_id       = var.vpc_id

  tags = {
    Environment  = local.name
  }
}

module "eks_cluster" {
  source  = "../../modules/eks_cluster"

  environment = "blue"
  name        = "${local.name}_${local.cluster_name}"

  cluster_version = "1.29"
  eks_admin_role_name = local.eks_admin_role_name

  instance_types = ["m5.large"]

  vpc_id      = local.vpc_id
  aws_region  = local.region

  eks_addons  = [ {  "name"    = "coredns", 
                    "version" = "v1.11.1-eksbuild.4"},
                  {  "name"    = "aws-ebs-csi-driver", 
                    "version" = "v1.29.1-eksbuild.1"},
                  {  "name"    = "amazon-cloudwatch-observability", 
                    "version" = "v1.4.0-eksbuild.1"}]
}
