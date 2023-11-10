variable "vpc_cidr" {
    description = "vraible for vpc-cidr"
    type = string
}

variable "public_subnets_cidr"{
    description = "varaible for public subnet"
    type = list(string)
}

variable "private_subnets_cidr"{
    description = "varaible for public subnet"
    type = list(string)
}

variable "env" {
    type = string
}

variable "availability_zones" {
    description = "availability_zones for subnets"
    type = list(string)
}
