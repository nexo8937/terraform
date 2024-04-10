################
##  Provider  ##
################

provider "aws" {
  region = var.region
}

###############
##  NETWORK  ##
###############

#data
data "aws_availability_zones" "working" {}

#VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.app}-vpc"
  }
}

#Public Subnets
resource "aws_subnet" "pub-sub-A" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_A_cidr_block
  availability_zone       = data.aws_availability_zones.working.names[0]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.app}-public-subnet-A"
  }
}

resource "aws_subnet" "pub-sub-B" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_sub_B_cidr_block
  availability_zone       = data.aws_availability_zones.working.names[1]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.app}-public-subnet-B"
  }
}

#Private Subnets
resource "aws_subnet" "priv-sub-A" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sub_A_cidr_block
  availability_zone = data.aws_availability_zones.working.names[0]
  tags = {
    Name = "${var.app}-private-subnet-A"
  }
}

resource "aws_subnet" "priv-sub-B" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_sub_B_cidr_block
  availability_zone = data.aws_availability_zones.working.names[1]
  tags = {
    Name = "${var.app}-private-subnet-B"
  }
}

#Elastic Ip for Nat
resource "aws_eip" "elastic-ip" {
  tags = {
    Name = "${var.app}-elastic-ip"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.app}-intenet-gateway"
  }
}

#NAT gateway
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip.id
  subnet_id     = aws_subnet.pub-sub-A.id
  tags = {
    Name = "${var.app}-nat-gateway"
  }
}

#Route table for Public Subnets
resource "aws_route_table" "pub-route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.app}-public-route"
  }
}

#Add Public Subnets to Route
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.pub-sub-A.id
  route_table_id = aws_route_table.pub-route.id
}

resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.pub-sub-B.id
  route_table_id = aws_route_table.pub-route.id
}

#Route table for Private Subnets
resource "aws_route_table" "priv-route" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name = "${var.app}-private-route"
  }
}

#Add Private Subnets to Route
resource "aws_route_table_association" "priv-1" {
  subnet_id      = aws_subnet.priv-sub-A.id
  route_table_id = aws_route_table.priv-route.id
}

resource "aws_route_table_association" "priv-2" {
  subnet_id      = aws_subnet.priv-sub-B.id
  route_table_id = aws_route_table.priv-route.id
}


#EC2 Role
resource "aws_iam_role" "ecr_role" {
  name = "ecr-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

#Attach Policy to Role
resource "aws_iam_policy_attachment" "ecr_policy_attachment" {
  name       = "AmazonEC2ContainerRegistryFullAccess"
  roles      = [aws_iam_role.ecr_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

#EC2 Instance Profile
resource "aws_iam_instance_profile" "ecr_instance_profile" {
  name = "${var.app}-ecr-instance-profile"
  role = aws_iam_role.ecr_role.name

}

###########
##  ECR  ##
###########

resource "aws_ecr_repository" "ecr-repo" {
  name                 = var.ecr-repo-name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
