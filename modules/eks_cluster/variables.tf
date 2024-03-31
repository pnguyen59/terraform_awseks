variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "environment" {
  description = "The name of the environment of EKS cluster"
  type        = string
}

variable "name" {
  description = "The name of EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "The Version of Kubernetes to deploy"
  type        = string
  default     = "1.29"
}

variable "eks_admin_role_name" {
  type        = string
  description = "Additional IAM role to be admin in the cluster"
  default     = ""
}



