locals {
  name_prefix = "s-api-${var.env}"
}

resource "aws_vpc" "shared_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shared_vpc.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.shared_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${local.name_prefix}-PublicWorkerSubnet0${count.index + 1}"
    "kubernetes.io/role/elb" = "1" # Required for public subnets in EKS
  }
}

# Private Worker Subnets
resource "aws_subnet" "private_worker" {
  count             = length(var.private_worker_subnet_cidrs)
  vpc_id            = aws_vpc.shared_vpc.id
  cidr_block        = var.private_worker_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                              = "${local.name_prefix}-PrivateWorkerSubnet0${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1" # Required for private subnets in EKS
  }
}

# Private Cluster Subnets
resource "aws_subnet" "private_cluster" {
  count             = length(var.private_cluster_subnet_cidrs)
  vpc_id            = aws_vpc.shared_vpc.id
  cidr_block        = var.private_cluster_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                              = "${local.name_prefix}-PrivateClusterSubnet0${count.index + 1}"
    "kubernetes.io/role/internal-elb" = "1" # Required for private subnets in EKS
  }
}


resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${local.name_prefix}-eip"
  }
}

# # NAT Gateways
resource "aws_nat_gateway" "natgateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${local.name_prefix}-nat-gw"
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.shared_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name_prefix} Public Subnet RouteTable "
  }
}


# Private Route Tables
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.shared_vpc.id

  tags = {
    Name = "Private Subnet RouteTable"
  }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgateway.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private worker subnets with private route tables
resource "aws_route_table_association" "private_worker" {
  count          = length(aws_subnet.private_worker)
  subnet_id      = aws_subnet.private_worker[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate private cluster subnets with private route tables
resource "aws_route_table_association" "private_cluster" {
  count          = length(aws_subnet.private_cluster)
  subnet_id      = aws_subnet.private_cluster[count.index].id
  route_table_id = aws_route_table.private.id
}
