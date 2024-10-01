# Find the user currently in use by AWS
data "aws_caller_identity" "current" {}

locals {
  private_subnets = var.private_subnets
}



resource "aws_security_group" "allow_to_eks" {
  name        = "allow_to_eks"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_to_eks"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_all" {
  security_group_id = aws_security_group.allow_to_eks.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# data "aws_security_group" "eks_additional_sg" {
#   tags = {
#     Name = "allow_to_eks"
#   }
# }

# #Add Tags for the private cluster in the VPC Subnets for elb
resource "aws_ec2_tag" "private_subnets" {
  for_each    = toset(local.private_subnets)
  resource_id = each.value
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}


module "eks" {
  # depends_on = [module.vpc]
  source  = "terraform-aws-modules/eks/aws"
  # version = "~> 19.15.2"
  # cluster_security_group_id = aws_security_group.allow_to_eks.id
  cluster_security_group_additional_rules = {
    ingress_allow_all = {
      type                          = "ingress"
      protocol                      = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      from_port                     = 0
      to_port                       = 0
      description                   = "Allow all inbound traffic"
    }
  }
  create_iam_role = false
  iam_role_arn = var.eks_admin_role_name
  # create_kms_key = false
  version = "~> 20.23.0"
  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = false
  vpc_id = local.vpc_id
  subnet_ids = local.private_subnets
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_private_access = true
  
   
  #we uses only 1 security group to allow connection with Fargate, MNG, and Karpenter nodes
  create_node_security_group = false
  eks_managed_node_groups = {
    initial = {
      node_group_name = local.node_group_name
      instance_types  = local.instance_types
      # iam_role_attach_cni_policy = true
      min_size     = 1
      max_size     = 5
      desired_size = 3
      # subnet_ids   = data.aws_subnets.eks-list-subnet.ids
      subnet_ids   = local.private_subnets
    }
  }
  cluster_addons = {
    coredns = {
      addon_name        = "coredns"
      addon_version     = "v1.11.1-eksbuild.9" # Replace with the desired CoreDNS version
      resolve_conflicts = "OVERWRITE"
    }
  }
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


resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.12.0"
  namespace  = "cert-manager"
    create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  
  depends_on = [ module.eks ]
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  # version    = "1.4.4"

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

resource "aws_eks_addon" "adot" {
  cluster_name      = module.eks.cluster_name
  addon_name        = "adot"
  addon_version     = "v0.102.0-eksbuild.1"
  resolve_conflicts = "OVERWRITE"

  depends_on = [module.eks]
}

resource "aws_iam_role" "adot_collector" {
  name = "adot-collector-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${module.eks.oidc_provider}:sub" = "system:serviceaccount:opentelemetry-operator-system:adot-collector"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "adot_collector_cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.adot_collector.name
}


resource "helm_release" "adot_collector" {
  name       = "adot-collector"
  repository = "https://aws-observability.github.io/aws-otel-helm-charts"
  chart      = "adot-exporter-for-eks-on-ec2"
  namespace  = "opentelemetry-operator-system"
  version    = "0.7.0"  # Replace with the latest version

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }
   set {
    name  = "serviceAccount.create"
    value = "true"
  }
 set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.adot_collector.arn
  }

  depends_on = [aws_eks_addon.adot]
}

# resource "kubernetes_annotations" "adot_collector_sa" {
#   api_version = "v1"
#   kind        = "ServiceAccount"
#   metadata {
#     name      = "adot-collector"
#     namespace = "opentelemetry-operator-system"
#   }
#   annotations = {
#     "eks.amazonaws.com/role-arn" = aws_iam_role.adot_collector.arn
#   }

#   depends_on = [aws_eks_addon.adot]
# }
