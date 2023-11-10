resource "aws_vpc" "eks_vpc" {
    cidr_block = "${var.vpc_cidr}"
    instance_tenancy = "default"
    tags = {
        Name = "${var.env}-vpc"
        Environment = "${var.env}"
    }
}

resource "aws_subnet" "eks_public_subnet" {
    vpc_id = aws_vpc.eks_vpc.id
    count  = "${length(var.public_subnets_cidr)}"
    cidr_block = "${element(var.public_subnets_cidr,   count.index)}"
    availability_zone = "${element(var.availability_zones,   count.index)}"
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.env}-${element(var.availability_zones, count.index)}-public-subnet"
      Environment = "${var.env}"
    }
}

resource "aws_subnet" "eks_private_subnet" {
    vpc_id = aws_vpc.eks_vpc.id
    count  = "${length(var.private_subnets_cidr)}"
    cidr_block = "${element(var.private_subnets_cidr, count.index)}"
    availability_zone = "${element(var.availability_zones,   count.index)}"
    map_public_ip_on_launch = false
    tags = {
      Name = "${var.env}-${element(var.availability_zones, count.index)}-private-subnet"
      Environment = "${var.env}"
    }
}

resource "aws_internet_gateway" "eks_igw" {
    vpc_id = aws_vpc.eks_vpc.id
    tags = {
    Name        = "${var.env}-igw"
    Environment = "${var.env}"
    }  
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  depends_on = [aws_internet_gateway.eks_igw]
}

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = "${element(aws_subnet.eks_public_subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.eks_igw]
  tags = {
    Name        = "nat"
    Environment = "${var.env}"
  }
}

resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.eks_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.eks_nat.id
    }
    tags = {
    Name        = "${var.env}-private-route-table"
    Environment = "${var.env}"
    }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.eks_igw.id
  }
  tags = {
    Name        = "${var.env}-public-route-table"
    Environment = "${var.env}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.eks_public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.eks_private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

resource "aws_security_group" "eks-sg" {
  name        = "${var.env}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.eks_vpc.id
  depends_on  = [aws_vpc.eks_vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self      = true
  }
  
  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self      = "true"
  }
  tags = {
    Environment = "${var.env}"
  }
}