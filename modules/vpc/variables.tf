variable "name" {
  description = "The name of VPC."
  type        = string
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

variable "tags" {
  type        = map
  description = "Tags for infrastructure resources."
  default     = {}
}

variable "private_subnet_cidrs" {
  description = "CIDR block for private subnet."
  type = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "eks_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}
variable "aurora_db_subnet" {
  type = list(string)
}