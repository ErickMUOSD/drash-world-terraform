variable "vpc_id"               { type = string }
variable "igw_id"               { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "azs"                  { type = list(string) }
variable "name"                 { type = string }
