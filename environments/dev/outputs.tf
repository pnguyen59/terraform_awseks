output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.eks_cluster.eks_cluster_id
}

