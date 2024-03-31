variable "environment_name" {
  description = "The name of environment Infrastructure stack, feel free to rename it. Used for cluster and VPC names."
  type        = string
  default     = "eks-blueprint"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  #default     = "us-west-2"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "cluster_name" {
  description = "The base name of EKS cluster"
  type        = string
}

variable "eks_admin_role_name" {
  type        = string
  description = "Additional IAM role to be admin in the cluster"
  default     = ""
}