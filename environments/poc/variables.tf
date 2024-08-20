variable "environment_name" {
  description = "The name of environment Infrastructure stack, feel free to rename it. Used for cluster and VPC names."
  type        = string
  default     = "eks-backbase-poc"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_ids" {
  description = "list of private subnet."
  type = list(string)
}

variable "public_subnet_ids" {
  description = "list of public subnnet"
  type        = list(string)
}

variable "eks_subnet_ids" {
  description = "list of subnet for eks"
  type        = list(string)
}

variable "vpc_id"{
  description = "VPC id"
  type = string
}