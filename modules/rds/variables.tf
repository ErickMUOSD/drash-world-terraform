
variable "subnet_ids" {
  type        = list(string)
}

variable "db_name" {
}

variable "db_user" {
}

variable "db_password" {
  sensitive   = true
}

variable "instance_class" {

}
variable "sg_rds" {
  type        = list(string)

}
