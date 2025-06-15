variable "vpc_id" {}
variable "private_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }
variable "public_subnet_id_for_nat" {}
variable "name" {}
