output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}


output "node_instance_public_ip" {
  value = aws_instance.eks_node_instance.public_ip
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.eks.certificate_authority[0].data

}

