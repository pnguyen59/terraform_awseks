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

variable "instance_types" {
  type        = list
  description = "eks_managed_node_groups instance_types"
  default     = ["m5.large"]
}

variable "eks_addons" {
  type        = list
  description = "eks addons"
}

variable "tags" {
  type        = map
  description = "Tags for infrastructure resources."
  default     = {}
}

variable "private_subnets" {
  type =list
}