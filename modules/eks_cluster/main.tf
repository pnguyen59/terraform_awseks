# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

locals {
  private_subnets = var.private_subnets
}




# #Add Tags for the private cluster in the VPC Subnets for elb
resource "aws_ec2_tag" "private_subnets" {
  # for_each    = toset(local.public_subnets)
  for_each    = toset(local.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}


module "eks" {
  # depends_on = [module.vpc]
  source  = "terraform-aws-modules/eks/aws"
  # version = "~> 19.15.2"
  version = "~> 20.23.0"
  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true
  vpc_id = local.vpc_id
  # vpc_id     = data.aws_vpc.vpc.id
  # subnet_ids = data.aws_subnets.private.ids
  # subnet_ids = data.aws_subnets.eks-list-subnet.ids
  subnet_ids = local.private_subnets
  enable_cluster_creator_admin_permissions = true

  
  #we uses only 1 security group to allow connection with Fargate, MNG, and Karpenter nodes
  create_node_security_group = false
  eks_managed_node_groups = {
    initial = {
      node_group_name = local.node_group_name
      instance_types  = local.instance_types

      min_size     = 1
      max_size     = 5
      desired_size = 3
      # subnet_ids   = data.aws_subnets.eks-list-subnet.ids
      subnet_ids   = local.private_subnets
    }
  }
  # node_security_group_additional_rules ={
  #   ingress_allow_access_from_control_plane = {
  #     type                          = "ingress"
  #     protocol                      = "tcp"
  #     from_port                     = 9443
  #     to_port                       = 9443
  #     source_cluster_security_group = true
  #     description                   = "Allow access from control plane to webhook port of AWS load balancer controller"
  #   }
  # }
  tags = local.tags
}

data "aws_eks_cluster" "default" {
  depends_on = [ module.eks ]
  name = module.eks.cluster_name
}
data "aws_eks_cluster_auth" "default" {
  depends_on = [ module.eks ]
  name = module.eks.cluster_name
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
      command     = "aws"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
  # host                   = data.aws_eks_cluster.default.endpoint
  # cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
  # # token                  = data.aws_eks_cluster_auth.default.token

  # exec {
  #   api_version = "client.authentication.k8s.io/v1beta1"
  #   args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.default.id]
  #   command     = "aws"
  # }
}

module "aws_load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.1"

  role_name = "aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}


resource "helm_release" "aws_load_balancer_controller" {
  
  depends_on = [ module.eks ]
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.4"

  set{
    name="vpcId"
    value = local.vpc_id
  }
  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.aws_load_balancer_controller_irsa_role.iam_role_arn
  }
}