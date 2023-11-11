
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_control_plane_role.arn
  vpc_config {
    subnet_ids = var.private_subnets_id
    endpoint_public_access = true
  }

  depends_on = [ aws_iam_role.eks_control_plane_role,
  aws_iam_role_policy_attachment.amazoneksclusterpolicy,
  aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy]
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnets_id
  instance_types  = var.instance_type
  scaling_config {
    desired_size = 3
    max_size     = 3
    min_size     = 2
    }
    tags = {
      Name = "Node"
    }
    depends_on = [ aws_iam_role_policy_attachment.eks_node_role_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_cni_policy_attachment,
    aws_iam_role_policy_attachment.eks_node_ecr_policy_attachment,
    aws_eks_cluster.eks]
}

resource "aws_instance" "eks_node_instance" {
  depends_on = [aws_eks_node_group.node_group] # Condition to create the EC2 instance after node group
  ami           = "ami-0e783882a19958fff"  # Specify the appropriate AMI ID for your instance
  instance_type = "t2.medium"               # Specify the desired instance type
  subnet_id     = var.public_subnets_id[0]        # Choose one of your private subnets
  associate_public_ip_address = true
  security_groups = var.security_group_id
  key_name      = "ekscluster"         # Specify your SSH key pair
  #iam_instance_profile = aws_iam_instance_profile.eks_instance_profile.name
  tags = {
    Name = "Node_Instance"
  }

  user_data = <<-EOF
              #!/bin/bash
              set -o xtrace
              sudo apt update
              sudo apt-get install -y apt-transport-https ca-certificates curl gpg
              curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
              echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
              sudo apt update
              sudo apt install zip
              curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
              unzip awscliv2.zip
              sudo ./aws/install          # Install AWS CLI
              sudo apt install -y kubectl         # Install kubectl
              EOF
}
#aws eks --region us-east-1 update-kubeconfig --name techit_cluster
              #kubectl apply -f /path/to/config-map.yaml # Update with your ConfigMap file path
              #kubectl get nodes

