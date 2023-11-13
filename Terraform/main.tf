provider "aws" {
    region = "us-east-1"
}

module "vpc" {
    source = "./Modules/vpc"
    vpc_cidr = "10.27.0.0/16"
    public_subnets_cidr = ["10.27.1.0/24","10.27.2.0/24","10.27.3.0/24"]
    private_subnets_cidr = ["10.27.5.0/24","10.27.6.0/24","10.27.7.0/24"]
    env = "dev"
    availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
}

module "eks" {
    source = "./Modules/eks"
    cluster_name = "techit_cluster"
    node_group_name = "group1"
    instance_type = ["t2.medium", "t2.medium", "t2.medium"] 
    private_subnets_id = [module.vpc.private_subnets_id[0], module.vpc.private_subnets_id[1], module.vpc.private_subnets_id[2]]
    public_subnets_id = [module.vpc.public_subnets_id[0]]
    security_group_id = [module.vpc.security_group_id]
    #count = length(module.vpc.private_subnets_id)
    }

output "node_instance_pub_ip" {
    value = module.eks.eks_node_instance_public_ip 
}
output "kubernetes-endpoint" {
    value = module.eks.eks_cluster_endpoint
  
}