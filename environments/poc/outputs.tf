output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.vpc_id
}

output "iam_arn" {
  description = "The ARN of IAM"
  value       = module.eks_iam.iam_arn
}

output "iam_name" {
  description = "The ARN of IAM"
  value       = module.eks_iam.iam_name
}