variable "db_subnet_group" {
  description = "db_subnet_group"
  type = string
}
#  variable "db_subnets" {
#    description = "db_subnet"
#    type = list(string)
#  }

 variable "vpc_id" {
   type = string
 }
 variable "azs" {
   type = list(string)
 }