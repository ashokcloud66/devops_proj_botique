variable "cluster_name" {
  type = string
}
variable "node_group_name" {
  type = string
}
variable "instance_type" {
  type = list(string) 
}

variable "private_subnets_id" {
  
}

variable "public_subnets_id" {
  
}
variable "security_group_id" {}