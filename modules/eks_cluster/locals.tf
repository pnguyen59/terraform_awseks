locals {
  #service     = var.service_name

  vpc_id      = var.vpc_id
  vpc_name    = data.aws_vpc.vpc.tags["Name"]

  environment  = var.environment
  name = "${local.environment}_${var.name}"

  cluster_version            = var.cluster_version
  eks_admin_role_name        = var.eks_admin_role_name
  
  tag_val_public_subnet  = "${local.vpc_name}-public-"
  tag_val_private_subnet = "${local.vpc_name}-private-"

  node_group_name = "managed-ondemand"
  instance_types  = var.instance_types
  eks_addons      = var.eks_addons
}

