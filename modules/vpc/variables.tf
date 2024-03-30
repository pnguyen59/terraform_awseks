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