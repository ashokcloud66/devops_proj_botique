output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "public_subnets_id" {
    value = aws_subnet.eks_public_subnet[*].id
}

output "private_subnets_id" {
    value = aws_subnet.eks_private_subnet[*].id
}
output "security_group_id" {
    value = aws_security_group.eks-sg.id  
}