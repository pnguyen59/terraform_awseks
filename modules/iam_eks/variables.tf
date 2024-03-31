variable "name" {
  description = "The name of IAM."
  type        = string
}

variable "tags" {
  type        = map
  description = "Tags for infrastructure resources."
  default     = {}
}